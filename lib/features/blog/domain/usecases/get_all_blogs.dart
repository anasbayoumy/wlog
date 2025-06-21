import 'package:fpdart/fpdart.dart';
import 'package:wlog/core/error/failures.dart';
import 'package:wlog/core/usecase/usecase.dart';
import 'package:wlog/features/blog/domain/entities/blog.dart';
import 'package:wlog/features/blog/domain/repos/blog_repo.dart';

class GetAllBlogs implements Usecase<List<Blog>, NoParams> {
  final BlogRepo blogRepo;
  GetAllBlogs(this.blogRepo);

  @override
  Future<Either<Failure, List<Blog>>> call(NoParams params) async {
    return await blogRepo.getAllBlogs();
  }
}
