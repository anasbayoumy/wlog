import 'package:wlog/features/blog/domain/entities/blog.dart';

class BlogModel extends Blog {
  BlogModel({
    required super.id,
    required super.title,
    required super.content,
    required super.image,
    required super.topics,
    required super.createdAt,
    required super.posterId,
    super.posterName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image_url': image,
      'topics': topics,
      // 'created_at': createdAt.toIso8601String(), // Commented out - column doesn't exist
      'poster_id': posterId,
      // 'name': posterName,
    };
  }

  factory BlogModel.fromJson(Map<String, dynamic> map) {
    return BlogModel(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      image: map['image_url'] as String,
      topics: (map['topics'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: map['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['created_at']),
      posterId: map['poster_id'] as String,
      posterName: map['name'] as String?,
    );
  }
  BlogModel copyWith({
    String? id,
    String? title,
    String? content,
    String? image,
    List<String>? topics,
    DateTime? createdAt,
    String? posterId,
    String? posterName,
  }) {
    return BlogModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      image: image ?? this.image,
      topics: topics ?? this.topics,
      createdAt: createdAt ?? this.createdAt,
      posterId: posterId ?? this.posterId,
      posterName: posterName ?? this.posterName,
    );
  }
}
