import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wlog/core/usecase/usecase.dart';
import 'package:wlog/features/blog/domain/entities/blog.dart';
import 'package:wlog/features/blog/domain/repos/blog_repo.dart';
import 'package:wlog/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:wlog/features/blog/domain/usecases/get_all_blogs_for_analytics.dart';
import 'package:wlog/features/blog/domain/usecases/upload_blog.dart';

part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final UploadBlogUseCase uploadBlogUseCase;
  final BlogRepo blogRepo;
  final GetAllBlogs getAllBlogs;
  final GetAllBlogsForAnalytics getAllBlogsForAnalytics;

  BlogBloc({
    required this.uploadBlogUseCase,
    required this.blogRepo,
    required this.getAllBlogs,
    required this.getAllBlogsForAnalytics,
  }) : super(BlogInitial()) {
    on<UploadBlogEvent>(_onUploadBlog);
    on<GetAllBlogsEvent>(_getAllBlogs);
    on<GetAllBlogsForAnalyticsEvent>(_getAllBlogsForAnalytics);
    // on<BlogEvent>((event, emit) => emit(BlogLoading()));
  }

  void _onUploadBlog(UploadBlogEvent event, Emitter<BlogState> emit) async {
    try {
      emit(BlogLoading());
      print('BlogBloc: Starting upload process'); // Debug log
      print('BlogBloc: Title: ${event.title}'); // Debug log
      print('BlogBloc: Content length: ${event.content.length}'); // Debug log
      print('BlogBloc: Topics: ${event.topics}'); // Debug log
      print('BlogBloc: PosterId: ${event.posterId}'); // Debug log

      final result = await uploadBlogUseCase(UploadBlogParams(
        image: event.image,
        title: event.title,
        content: event.content,
        topics: event.topics,
        posterId: event.posterId,
        webImage: event.webImage,
      ));

      result.fold(
        (failure) {
          print('BlogBloc: Upload failed: ${failure.message}'); // Debug log
          emit(BlogFailure(message: failure.message));
        },
        (blog) {
          print('BlogBloc: Upload successful'); // Debug log
          emit(BlogUploadSuccess());
        },
      );
    } catch (e) {
      print('BlogBloc: Exception occurred: $e'); // Debug log
      emit(BlogFailure(message: 'Upload failed: ${e.toString()}'));
    }
  }

  void _getAllBlogs(GetAllBlogsEvent event, Emitter<BlogState> emit) async {
    try {
      emit(BlogLoading());
      print('BlogBloc: Fetching all blogs'); // Debug log

      final result = await getAllBlogs(NoParams());

      result.fold(
        (failure) {
          print(
              'BlogBloc: Failed to fetch blogs: ${failure.message}'); // Debug log
          emit(BlogFailure(message: failure.message));
        },
        (blogs) {
          print(
              'BlogBloc: Successfully fetched ${blogs.length} blogs'); // Debug log
          emit(BlogDisplaySuccess(blogs: blogs));
        },
      );
    } catch (e) {
      print(
          'BlogBloc: Exception occurred while fetching blogs: $e'); // Debug log
      emit(BlogFailure(message: 'Failed to fetch blogs: ${e.toString()}'));
    }
  }

  void _getAllBlogsForAnalytics(
      GetAllBlogsForAnalyticsEvent event, Emitter<BlogState> emit) async {
    try {
      emit(BlogLoading());
      print('BlogBloc: Fetching all blogs for analytics'); // Debug log

      final result = await getAllBlogsForAnalytics(NoParams());

      result.fold(
        (failure) {
          print(
              'BlogBloc: Failed to fetch analytics blogs: ${failure.message}'); // Debug log
          emit(BlogFailure(message: failure.message));
        },
        (blogs) {
          print(
              'BlogBloc: Successfully fetched ${blogs.length} blogs for analytics'); // Debug log
          emit(BlogAnalyticsSuccess(blogs: blogs));
        },
      );
    } catch (e) {
      print(
          'BlogBloc: Exception occurred while fetching analytics blogs: $e'); // Debug log
      emit(BlogFailure(
          message: 'Failed to fetch analytics blogs: ${e.toString()}'));
    }
  }
}
