import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wlog/core/error/exceptions.dart';
import 'package:wlog/features/blog/data/model/blog_model.dart';

abstract interface class BlogRemoteDataSource {
  Future<BlogModel> uploadBlog(BlogModel blog);
  Future<String> uploadBlogImage(File image, String blogId);
}

class BlogRemoteDataSourceImpl implements BlogRemoteDataSource {
  final SupabaseClient supabaseClient;
  BlogRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<BlogModel> uploadBlog(BlogModel blog) async {
    try {
      final response = await supabaseClient
          .from('blogs')
          .insert(blog.toJson())
          .select()
          .single();
      return BlogModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> uploadBlogImage(File image, String blogId) async {
    try {
      await supabaseClient.storage.from('blog_images').upload(blogId, image);
      return supabaseClient.storage.from('blog_images').getPublicUrl(blogId);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
