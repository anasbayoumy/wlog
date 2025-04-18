import 'dart:io';

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
  }

  void _onUploadBlog(UploadBlogEvent event, Emitter<BlogState> emit) async {
    try {
      emit(BlogLoading());
      final result = await uploadBlogUseCase(UploadBlogParams(
        image: event.image,
        title: event.title,
        content: event.content,
        topics: event.topics,
        posterId: event.posterId,
      ));

      result.fold(
        (failure) => emit(BlogFailure(message: failure.message)),
        (blog) => emit(BlogSuccess()),
      );
    } catch (e) {
      emit(BlogFailure(message: e.toString()));
    }
  }
}
