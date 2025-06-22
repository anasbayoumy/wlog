import 'package:wlog/features/chat/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  ChatMessageModel({
    required super.id,
    required super.groupId,
    required super.senderId,
    required super.senderName,
    required super.content,
    required super.createdAt,
    required super.isMe,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    return ChatMessageModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String? ?? 'Unknown User',
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isMe: json['sender_id'] as String == currentUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'sender_id': senderId,
      'sender_name': senderName,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  ChatMessageModel copyWith({
    String? id,
    String? groupId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? createdAt,
    bool? isMe,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isMe: isMe ?? this.isMe,
    );
  }
}
