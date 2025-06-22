import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wlog/core/usecase/usecase.dart';
import 'package:wlog/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:wlog/features/chat/domain/entities/chat_group.dart';
import 'package:wlog/features/chat/domain/entities/chat_message.dart';
import 'package:wlog/features/chat/domain/repositories/chat_repository.dart';
import 'package:wlog/features/chat/domain/usecases/get_chat_groups.dart';
import 'package:wlog/features/chat/domain/usecases/get_messages.dart';
import 'package:wlog/features/chat/domain/usecases/send_message.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatGroups getChatGroups;
  final GetMessages getMessages;
  final SendMessage sendMessage;
  final ChatRepository chatRepository;

  StreamSubscription<ChatMessage>? _messageSubscription;
  List<ChatMessage> _currentMessages = [];
  String? _currentGroupId;
  List<ChatGroup>? _cachedGroups; // Cache groups to prevent disappearing

  ChatBloc({
    required this.getChatGroups,
    required this.getMessages,
    required this.sendMessage,
    required this.chatRepository,
  }) : super(ChatInitial()) {
    on<LoadChatGroups>(_onLoadChatGroups);
    on<RefreshChatGroups>(_onRefreshChatGroups);
    on<LoadMessages>(_onLoadMessages);
    on<RefreshMessages>(_onRefreshMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<SubscribeToMessages>(_onSubscribeToMessages);
    on<NewMessageReceived>(_onNewMessageReceived);
  }

  void _onLoadChatGroups(LoadChatGroups event, Emitter<ChatState> emit) async {
    try {
      // If we have cached groups and are not explicitly refreshing, use cache
      if (_cachedGroups != null && _cachedGroups!.isNotEmpty) {
        emit(ChatGroupsLoaded(groups: _cachedGroups!));
        return;
      }

      emit(ChatLoading());
      final result = await getChatGroups(NoParams());

      result.fold(
        (failure) => emit(ChatError(message: failure.message)),
        (groups) {
          _cachedGroups = groups; // Cache the groups
          emit(ChatGroupsLoaded(groups: groups));
        },
      );
    } catch (e) {
      emit(ChatError(message: 'Failed to load chat groups: ${e.toString()}'));
    }
  }

  void _onRefreshChatGroups(
      RefreshChatGroups event, Emitter<ChatState> emit) async {
    try {
      // Clear cache and force refresh
      _cachedGroups = null;
      emit(ChatLoading());

      final result = await getChatGroups(NoParams());

      result.fold(
        (failure) => emit(ChatError(message: failure.message)),
        (groups) {
          _cachedGroups = groups; // Cache the groups
          emit(ChatGroupsLoaded(groups: groups));
        },
      );
    } catch (e) {
      emit(
          ChatError(message: 'Failed to refresh chat groups: ${e.toString()}'));
    }
  }

  void _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    try {
      emit(ChatLoading());
      _currentGroupId = event.groupId;

      final result = await getMessages(event.groupId);

      result.fold(
        (failure) => emit(ChatError(message: failure.message)),
        (messages) {
          _currentMessages = messages;
          emit(ChatMessagesLoaded(messages: messages, groupId: event.groupId));
        },
      );
    } catch (e) {
      emit(ChatError(message: 'Failed to load messages: ${e.toString()}'));
    }
  }

  void _onRefreshMessages(
      RefreshMessages event, Emitter<ChatState> emit) async {
    try {
      // Cancel current WebSocket subscription
      _messageSubscription?.cancel();

      // Clear current messages and reload
      _currentMessages.clear();
      _currentGroupId = event.groupId;

      emit(ChatLoading());

      // Reload messages from database
      final result = await getMessages(event.groupId);

      result.fold(
        (failure) => emit(ChatError(message: failure.message)),
        (messages) {
          _currentMessages = messages;
          emit(ChatMessagesLoaded(messages: messages, groupId: event.groupId));

          // Re-establish WebSocket connection after refresh
          Future.delayed(const Duration(milliseconds: 300), () {
            add(SubscribeToMessages(groupId: event.groupId));
          });
        },
      );
    } catch (e) {
      emit(ChatError(message: 'Failed to refresh messages: ${e.toString()}'));
    }
  }

  void _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    try {
      final result = await sendMessage(SendMessageParams(
        groupId: event.groupId,
        content: event.content,
        senderId: event.senderId,
        senderName: event.senderName,
      ));

      result.fold(
        (failure) => emit(ChatError(message: failure.message)),
        (message) {
          // Message will be received through real-time subscription
          emit(ChatMessageSent());
        },
      );
    } catch (e) {
      emit(ChatError(message: 'Failed to send message: ${e.toString()}'));
    }
  }

  void _onSubscribeToMessages(
      SubscribeToMessages event, Emitter<ChatState> emit) {
    try {
      // Cancel previous subscription
      _messageSubscription?.cancel();

      print('ChatBloc: Subscribing to WebSocket for group: ${event.groupId}');

      // Subscribe to WebSocket messages for real-time updates
      _messageSubscription =
          chatRepository.subscribeToMessages(event.groupId).listen(
        (message) {
          print('ChatBloc: Received WebSocket message: ${message.content}');
          add(NewMessageReceived(message: message));
        },
        onError: (error) {
          print('ChatBloc: WebSocket error: $error');
          emit(ChatError(
              message: 'Real-time connection error: ${error.toString()}'));
        },
        onDone: () {
          print('ChatBloc: WebSocket connection closed');
        },
      );
    } catch (e) {
      print('ChatBloc: Failed to subscribe to WebSocket: $e');
      emit(ChatError(
          message:
              'Failed to establish real-time connection: ${e.toString()}'));
    }
  }

  void _onNewMessageReceived(
      NewMessageReceived event, Emitter<ChatState> emit) {
    if (_currentGroupId == event.message.groupId) {
      // Check if message already exists to avoid duplicates
      final existingIndex =
          _currentMessages.indexWhere((msg) => msg.id == event.message.id);

      if (existingIndex == -1) {
        // New message, add it
        _currentMessages.add(event.message);

        // Sort messages by creation time
        _currentMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        // Only emit if this is actually a new message
        emit(ChatMessagesUpdated(
          messages: List.from(_currentMessages),
          groupId: _currentGroupId!,
        ));
      }
      // If message already exists, don't emit to prevent unnecessary rebuilds
    }
  }

  @override
  Future<void> close() {
    // Cancel WebSocket subscription
    _messageSubscription?.cancel();

    // Clean up WebSocket connections in repository
    if (chatRepository is ChatRepositoryImpl) {
      (chatRepository as ChatRepositoryImpl).dispose();
    }

    return super.close();
  }
}
