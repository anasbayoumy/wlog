import 'package:fpdart/fpdart.dart';
import 'package:wlog/core/error/exceptions.dart';
import 'package:wlog/core/error/failures.dart';
import 'package:wlog/features/auth/data/datasouces/auth_remote_data_source.dart';
import 'package:wlog/features/auth/domain/repo/auth_repo.dart';

class AuthRepoImp implements AuthRepo {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepoImp({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> logIn(
      {required String email, required String password}) {
    // TODO: implement logIn
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> signUp(
      {required String email,
      required String password,
      required String name}) async {
    try {
      final response = await remoteDataSource.signUp(
          email: email, password: password, name: name);
      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
