import 'package:fpdart/src/either.dart';
import 'package:wlog/core/error/failures.dart';
import 'package:wlog/core/usecase/usecase.dart';
import 'package:wlog/features/auth/domain/entities/user.dart';
import 'package:wlog/features/auth/domain/repo/auth_repo.dart';

class UserLogin implements Usecase<UserEntity, UserLoginParams> {
  final AuthRepo authRepo;
  UserLogin({required this.authRepo});

  @override
  Future<Either<Failure, UserEntity>> call(params) async {
    return await authRepo.logIn(
      email: params.email,
      password: params.password,
    );
  }
}

class UserLoginParams {
  final String email;
  final String password;

  UserLoginParams({required this.email, required this.password});
}
