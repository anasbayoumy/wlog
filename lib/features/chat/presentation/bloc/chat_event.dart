part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

class LoadChatGroups extends ChatEvent {}

class RefreshChatGroups extends ChatEvent {}

class LoadMessages extends ChatEvent {
  final String groupId;
  LoadMessages({required this.groupId});
}

class RefreshMessages extends ChatEvent {
  final String groupId;
  RefreshMessages({required this.groupId});
}

class SendMessageEvent extends ChatEvent {
  final String groupId;
  final String content;
  final String senderId;
  final String senderName;

  SendMessageEvent({
    required this.groupId,
    required this.content,
    required this.senderId,
    required this.senderName,
  });
}

class SubscribeToMessages extends ChatEvent {
  final String groupId;
  SubscribeToMessages({required this.groupId});
}

class NewMessageReceived extends ChatEvent {
  final ChatMessage message;
  NewMessageReceived({required this.message});
}

class WebSocketConnectionChanged extends ChatEvent {
  final bool isConnected;
  final String groupId;
  WebSocketConnectionChanged(
      {required this.isConnected, required this.groupId});
}
