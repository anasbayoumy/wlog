class ChatMessage {
  final String id;
  final String groupId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime createdAt;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.createdAt,
    required this.isMe,
  });

  ChatMessage copyWith({
    String? id,
    String? groupId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? createdAt,
    bool? isMe,
  }) {
    return ChatMessage(
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
