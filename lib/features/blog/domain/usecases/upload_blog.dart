import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:wlog/core/error/failures.dart';
import 'package:wlog/core/usecase/usecase.dart';
// import 'package:wlog/features/blog/data/model/blog_model.dart';
import 'package:wlog/features/blog/domain/entities/blog.dart';
import 'package:wlog/features/blog/domain/repos/blog_repo.dart';

class UploadBlogUseCase implements Usecase<Blog, UploadBlogParams> {
  final BlogRepo blogRepo;
  UploadBlogUseCase({required this.blogRepo});
  @override
  Future<Either<Failure, Blog>> call(UploadBlogParams params) async =>
      blogRepo.uploadBlog(params.image, params.title, params.content,
          params.topics, params.posterId);
}

class UploadBlogParams {
  final File image;
  final String title;
  final String content;
  final List<String> topics;
  final String posterId;

  UploadBlogParams({
    required this.image,
    required this.title,
    required this.content,
    required this.topics,
    required this.posterId,
  });
}
