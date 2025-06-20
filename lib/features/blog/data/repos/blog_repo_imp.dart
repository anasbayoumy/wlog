import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:wlog/core/error/failures.dart';
import 'package:wlog/features/blog/data/datasource/blog_remote_data_source.dart';
import 'package:wlog/features/blog/data/model/blog_model.dart';
import 'package:wlog/features/blog/domain/entities/blog.dart';
import 'package:wlog/features/blog/domain/repos/blog_repo.dart';

class BlogRepoImpl implements BlogRepo {
  final SupabaseClient supabaseClient;
  BlogRepoImpl({required this.supabaseClient});
  @override
  Future<Either<Failure, Blog>> uploadBlog(
    File image,
    String title,
    String content,
    List<String> topics,
    String posterId, {
    Uint8List? webImage,
  }) async {
    try {
      print('BlogRepo: Creating blog model'); // Debug log
      BlogModel blogModel = BlogModel(
          id: const Uuid().v1(),
          title: title,
          content: content,
          image: '',
          topics: topics,
          createdAt: DateTime.now(),
          posterId: posterId);

      print('BlogRepo: Uploading image for blog: ${blogModel.id}'); // Debug log
      final dataSource =
          BlogRemoteDataSourceImpl(supabaseClient: supabaseClient);

      final String imageUrl;
      if (kIsWeb && webImage != null) {
        print('BlogRepo: Using web image upload'); // Debug log
        imageUrl = await dataSource.uploadBlogImageWeb(
            webImage, blogModel.id, 'image.jpg');
      } else {
        print('BlogRepo: Using file image upload'); // Debug log
        imageUrl = await dataSource.uploadBlogImage(image, blogModel.id);
      }

      print('BlogRepo: Image uploaded, URL: $imageUrl'); // Debug log
      blogModel = blogModel.copyWith(image: imageUrl);

      print('BlogRepo: Uploading blog data'); // Debug log
      final blog =
          await BlogRemoteDataSourceImpl(supabaseClient: supabaseClient)
              .uploadBlog(blogModel);

      print('BlogRepo: Blog uploaded successfully'); // Debug log
      return right(blog);
    } catch (e) {
      print('BlogRepo: Error occurred: $e'); // Debug log
      return left(Failure('Blog upload failed: ${e.toString()}'));
    }
  }
}
