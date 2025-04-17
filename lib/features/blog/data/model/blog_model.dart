import 'package:wlog/features/blog/domain/entities/blog.dart';

class BlogModel extends Blog {
  BlogModel(
      {required super.id,
      required super.title,
      required super.content,
      required super.image,
      required super.topics,
      required super.createdAt,
      required super.posterId});
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image_url': image,
      'topics': topics,
      'created_at': createdAt,
      'poster_id': posterId,
    };
  }

  factory BlogModel.fromJson(Map<String, dynamic> map) {
    return BlogModel(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      image: map['image_url'] as String,
      topics: map['topics'] as List<String>,
      createdAt: map['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['created_at']),
      posterId: map['poster_id'],
    );
  }
}
