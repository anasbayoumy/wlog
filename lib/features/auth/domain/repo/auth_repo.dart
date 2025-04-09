import 'package:fpdart/fpdart.dart';
import 'package:wlog/core/error/failures.dart';
import '../entities/user.dart';

abstract interface class AuthRepo {
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String name,
  });
  Future<Either<Failure, UserEntity>> logIn({
    required String email,
    required String password,
  });
  Future<Either<Failure, UserEntity>> getCurrentUser();
}
