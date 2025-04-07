import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wlog/core/error/failures.dart';
import '../entities/user.dart';

// import 'package:wlog/features/auth/domain/entities/user.dart';
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
}
