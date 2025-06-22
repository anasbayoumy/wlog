part of 'chat_bloc.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

final class ChatLoading extends ChatState {}

final class ChatGroupsLoaded extends ChatState {
  final List<ChatGroup> groups;
  ChatGroupsLoaded({required this.groups});
}

final class ChatMessagesLoaded extends ChatState {
  final List<ChatMessage> messages;
  final String groupId;
  ChatMessagesLoaded({required this.messages, required this.groupId});
}

final class ChatMessagesUpdated extends ChatState {
  final List<ChatMessage> messages;
  final String groupId;
  ChatMessagesUpdated({required this.messages, required this.groupId});
}

final class ChatMessageSent extends ChatState {}

final class ChatError extends ChatState {
  final String message;
  ChatError({required this.message});
}
