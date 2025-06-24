import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wlog/core/error/exceptions.dart';
import 'package:wlog/features/chat/data/models/chat_group_model.dart';
import 'package:wlog/features/chat/data/models/chat_message_model.dart';

abstract interface class ChatRemoteDataSource {
  Future<List<ChatGroupModel>> getChatGroups();
  Future<List<ChatMessageModel>> getMessages(String groupId);
  Future<ChatMessageModel> sendMessage({
    required String groupId,
    required String content,
    required String senderId,
    required String senderName,
  });
  Stream<ChatMessageModel> subscribeToMessages(String groupId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient supabaseClient;
  final Map<String, StreamController<ChatMessageModel>> _messageControllers =
      {};
  final Map<String, RealtimeChannel> _channels = {};

  ChatRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ChatGroupModel>> getChatGroups() async {
    try {
      // Get unique categories from blogs to create chat groups
      final response = await supabaseClient
          .from('blogs')
          .select('topics')
          .not('topics', 'is', null);

      // Extract unique categories
      final Set<String> categories = {};
      for (final row in response) {
        final topics = row['topics'] as List<dynamic>?;
        if (topics != null) {
          categories.addAll(topics.cast<String>());
        }
      }

      // Create chat groups for each category
      final List<ChatGroupModel> groups = [];
      for (final category in categories) {
        // Get member count for this category (users who have blogs in this category)
        final memberCountResponse = await supabaseClient
            .from('blogs')
            .select('poster_id')
            .contains('topics', [category]);

        final uniqueMembers =
            memberCountResponse.map((row) => row['poster_id']).toSet().length;

        groups.add(ChatGroupModel(
          id: category.toLowerCase().replaceAll(' ', '_'),
          name: '$category Chat',
          category: category,
          createdAt: DateTime.now(),
          memberCount: uniqueMembers,
        ));
      }

      return groups;
    } catch (e) {
      throw ServerException(
          message: 'Failed to get chat groups: ${e.toString()}');
    }
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String groupId) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw ServerException(message: 'User not authenticated');
      }

      final response = await supabaseClient
          .from('chat_messages')
          .select('*')
          .eq('group_id', groupId)
          .order('created_at', ascending: true)
          .limit(100);

      return response
          .map((json) => ChatMessageModel.fromJson(json, currentUser.id))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get messages: ${e.toString()}');
    }
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String groupId,
    required String content,
    required String senderId,
    required String senderName,
  }) async {
    try {
      final messageData = {
        'group_id': groupId,
        'sender_id': senderId,
        'sender_name': senderName,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await supabaseClient
          .from('chat_messages')
          .insert(messageData)
          .select()
          .single();

      return ChatMessageModel.fromJson(response, senderId);
    } catch (e) {
      throw ServerException(message: 'Failed to send message: ${e.toString()}');
    }
  }

  @override
  Stream<ChatMessageModel> subscribeToMessages(String groupId) {
    final currentUser = supabaseClient.auth.currentUser;
    if (currentUser == null) {
      return Stream.error('User not authenticated');
    }

    // Clean up existing connection for this group to prevent duplicates
    if (_channels.containsKey(groupId)) {
      supabaseClient.removeChannel(_channels[groupId]!);
      _channels.remove(groupId);
    }

    if (_messageControllers.containsKey(groupId)) {
      _messageControllers[groupId]?.close();
      _messageControllers.remove(groupId);
    }

    // Create fresh stream controller for this group
    _messageControllers[groupId] =
        StreamController<ChatMessageModel>.broadcast();

    // Create Supabase real-time channel for WebSocket connection
    final channel = supabaseClient
        .channel('chat_${groupId}_${DateTime.now().millisecondsSinceEpoch}');
    _channels[groupId] = channel;

    // Subscribe to INSERT events on chat_messages table using WebSocket
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'group_id',
            value: groupId,
          ),
          callback: (payload) {
            try {
              // Handle new message via WebSocket
              final messageData = payload.newRecord;
              final message =
                  ChatMessageModel.fromJson(messageData, currentUser.id);

              // Only add if controller still exists and is not closed
              if (_messageControllers.containsKey(groupId) &&
                  !_messageControllers[groupId]!.isClosed) {
                _messageControllers[groupId]!.add(message);
              }
            } catch (e) {
              print('Error processing WebSocket message: $e');
              if (_messageControllers.containsKey(groupId) &&
                  !_messageControllers[groupId]!.isClosed) {
                _messageControllers[groupId]!.addError(e);
              }
            }
          },
        )
        .subscribe();

    return _messageControllers[groupId]!.stream;
  }

  // Clean up specific group connection
  void cleanupGroup(String groupId) {
    if (_channels.containsKey(groupId)) {
      supabaseClient.removeChannel(_channels[groupId]!);
      _channels.remove(groupId);
    }

    if (_messageControllers.containsKey(groupId)) {
      _messageControllers[groupId]?.close();
      _messageControllers.remove(groupId);
    }
  }

  // Clean up all resources when done
  void dispose() {
    for (final controller in _messageControllers.values) {
      controller.close();
    }
    for (final channel in _channels.values) {
      supabaseClient.removeChannel(channel);
    }
    _messageControllers.clear();
    _channels.clear();
  }
}
