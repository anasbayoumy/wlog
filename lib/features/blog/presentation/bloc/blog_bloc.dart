import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wlog/features/blog/domain/repos/blog_repo.dart';
import 'package:wlog/features/blog/domain/usecases/upload_blog.dart';

part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final UploadBlogUseCase uploadBlogUseCase;
  final BlogRepo blogRepo;

  BlogBloc({
    required this.uploadBlogUseCase,
    required this.blogRepo,
  }) : super(BlogInitial()) {
    on<UploadBlogEvent>(_onUploadBlog);
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
          emit(BlogSuccess());
        },
      );
    } catch (e) {
      print('BlogBloc: Exception occurred: $e'); // Debug log
      emit(BlogFailure(message: 'Upload failed: ${e.toString()}'));
    }
  }
}
