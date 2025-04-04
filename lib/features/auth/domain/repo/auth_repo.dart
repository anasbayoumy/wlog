import 'package:fpdart/fpdart.dart';
import 'package:wlog/core/error/failures.dart';

abstract interface class AuthRepo {
  Future<Either<Failure, String>> signUp({
    required String email,
    required String password,
    required String name,
  });
  Future<Either<Failure, String>> logIn({
    required String email,
    required String password,
  });
}
