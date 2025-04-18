import 'dart:io';
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
    String posterId,
  ) async {
    BlogModel blogModel = BlogModel(
        id: const Uuid().v1(),
        title: title,
        content: content,
        image: '',
        topics: topics,
        createdAt: DateTime.now(),
        posterId: posterId);

    final imageUrl =
        await BlogRemoteDataSourceImpl(supabaseClient: supabaseClient)
            .uploadBlogImage(image, blogModel.id);
    blogModel = blogModel.copyWith(image: imageUrl);
    try {
      final blog =
          await BlogRemoteDataSourceImpl(supabaseClient: supabaseClient)
              .uploadBlog(blogModel);
      return right(blog);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
