import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wlog/core/error/exceptions.dart';
import 'package:wlog/features/blog/data/model/blog_model.dart';

abstract interface class BlogRemoteDataSource {
  Future<BlogModel> uploadBlog(BlogModel blog);
  Future<String> uploadBlogImage(File image, String blogId);
  Future<String> uploadBlogImageWeb(
      Uint8List imageBytes, String blogId, String fileName);
}

class BlogRemoteDataSourceImpl implements BlogRemoteDataSource {
  final SupabaseClient supabaseClient;
  BlogRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<BlogModel> uploadBlog(BlogModel blog) async {
    try {
      print('Uploading blog with data: ${blog.toJson()}'); // Debug log
      final response = await supabaseClient
          .from('blogs')
          .insert(blog.toJson())
          .select()
          .single();
      print('Blog upload response: $response'); // Debug log
      return BlogModel.fromJson(response);
    } catch (e) {
      print('Upload blog error: $e'); // Debug log
      print('Blog data: ${blog.toJson()}'); // Debug log
      throw ServerException(message: 'Failed to upload blog: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadBlogImage(File image, String blogId) async {
    try {
      print('Uploading image for blog ID: $blogId'); // Debug log
      await supabaseClient.storage.from('blog_images').upload(blogId, image);
      final imageUrl =
          supabaseClient.storage.from('blog_images').getPublicUrl(blogId);
      print('Image uploaded successfully. URL: $imageUrl'); // Debug log
      return imageUrl;
    } catch (e) {
      print('Upload image error: $e'); // Debug log
      print('Blog ID: $blogId'); // Debug log
      throw ServerException(message: 'Failed to upload image: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadBlogImageWeb(
      Uint8List imageBytes, String blogId, String fileName) async {
    try {
      print('Uploading web image for blog ID: $blogId'); // Debug log
      await supabaseClient.storage
          .from('blog_images')
          .uploadBinary(blogId, imageBytes);
      final imageUrl =
          supabaseClient.storage.from('blog_images').getPublicUrl(blogId);
      print('Web image uploaded successfully. URL: $imageUrl'); // Debug log
      return imageUrl;
    } catch (e) {
      print('Upload web image error: $e'); // Debug log
      print('Blog ID: $blogId'); // Debug log
      throw ServerException(
          message: 'Failed to upload web image: ${e.toString()}');
    }
  }
}
