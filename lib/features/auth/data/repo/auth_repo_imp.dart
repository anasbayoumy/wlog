import 'package:fpdart/fpdart.dart';
import 'package:wlog/core/error/exceptions.dart';
import 'package:wlog/core/error/failures.dart';
import 'package:wlog/features/auth/data/datasouces/auth_remote_data_source.dart';
import 'package:wlog/core/common/entities/user.dart';
import 'package:wlog/features/auth/domain/repo/auth_repo.dart';

class AuthRepoImp implements AuthRepo {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepoImp({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.logIn(
        email: email,
        password: password,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final result = await remoteDataSource.signUp(
        email: email,
        password: password,
        name: name,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final result = await remoteDataSource.getCurrentUser();
      if (result == null) {
        return Left(Failure('User not found'));
      }
      return Right(result);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }
}
