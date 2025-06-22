import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wlog/core/error/exceptions.dart';
import 'package:wlog/features/blog/data/model/blog_model.dart';

abstract interface class BlogRemoteDataSource {
  Future<BlogModel> uploadBlog(BlogModel blog);
  Future<String> uploadBlogImage(File image, String blogId);
  Future<String> uploadBlogImageWeb(
      Uint8List imageBytes, String blogId, String fileName);
  Future<List<BlogModel>> getAllBlogs();
  Future<List<BlogModel>> getAllBlogsForAnalytics();
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

  @override
  Future<List<BlogModel>> getAllBlogs() async {
    try {
      // Get current user ID
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw ServerException(message: 'User not authenticated');
      }

      // Fetch only blogs for the current user
      final res = await supabaseClient
          .from('blogs')
          .select('* , profiles(name)')
          .eq('poster_id', currentUser.id);

      print('Fetched ${res.length} blogs for user: ${currentUser.id}');
      return res
          .map((res) => BlogModel.fromJson(res).copyWith(
                posterName: res['profiles']['name'],
              ))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<BlogModel>> getAllBlogsForAnalytics() async {
    try {
      // Fetch ALL blogs from ALL users for analytics
      final res = await supabaseClient
          .from('blogs')
          .select('*, profiles(name)')
          .order('updated_at', ascending: false);

      print('Fetched ${res.length} blogs for analytics');
      return res
          .map((res) => BlogModel.fromJson(res).copyWith(
                posterName: res['profiles']['name'],
              ))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
