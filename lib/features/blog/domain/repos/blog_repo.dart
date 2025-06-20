import 'dart:io';
import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';

import 'package:wlog/core/error/failures.dart';
import 'package:wlog/features/blog/domain/entities/blog.dart';

abstract interface class BlogRepo {
  Future<Either<Failure, Blog>> uploadBlog(
    File image,
    String title,
    String content,
    List<String> topics,
    String posterId, {
    Uint8List? webImage,
  });
}
