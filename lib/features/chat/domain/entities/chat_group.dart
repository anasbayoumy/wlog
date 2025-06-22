class ChatGroup {
  final String id;
  final String name;
  final String category;
  final DateTime createdAt;
  final int memberCount;

  ChatGroup({
    required this.id,
    required this.name,
    required this.category,
    required this.createdAt,
    required this.memberCount,
  });
}
