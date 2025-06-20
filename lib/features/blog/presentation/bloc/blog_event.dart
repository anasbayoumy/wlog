part of 'blog_bloc.dart';

@immutable
sealed class BlogEvent {}

// Add this field to your UploadBlogEvent class
class UploadBlogEvent extends BlogEvent {
  final File image;
  final String title;
  final String content;
  final List<String> topics;
  final String posterId;
  final Uint8List? webImage; // Add this field

  UploadBlogEvent({
    required this.image,
    required this.title,
    required this.content,
    required this.topics,
    required this.posterId,
    this.webImage, // Optional parameter for web
  });
}
