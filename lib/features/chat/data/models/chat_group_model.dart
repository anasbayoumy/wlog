import 'package:wlog/features/chat/domain/entities/chat_group.dart';

class ChatGroupModel extends ChatGroup {
  ChatGroupModel({
    required super.id,
    required super.name,
    required super.category,
    required super.createdAt,
    required super.memberCount,
  });

  factory ChatGroupModel.fromJson(Map<String, dynamic> json) {
    return ChatGroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      memberCount: json['member_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'member_count': memberCount,
    };
  }
}
