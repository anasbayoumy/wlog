import 'package:fpdart/fpdart.dart';
import 'package:wlog/core/error/failures.dart';
import 'package:wlog/core/usecase/usecase.dart';
import 'package:wlog/features/auth/domain/entities/user.dart';
import 'package:wlog/features/auth/domain/repo/auth_repo.dart';

class UserSignup implements Usecase<UserEntity, UserSignupParams> {
  final AuthRepo authRepo;
  UserSignup({required this.authRepo});

  @override
  Future<Either<Failure, UserEntity>> call(UserSignupParams params) async {
    return await authRepo.signUp(
      email: params.email,
      password: params.password,
      name: params.name,
      // username: params.username,
    );
  }
}

class UserSignupParams {
  final String email;
  final String password;
  final String name;
  // final String? username;

  UserSignupParams({
    required this.email,
    required this.password,
    required this.name,
    // this.username,
  });
}
