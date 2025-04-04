import 'package:fpdart/src/either.dart';
import 'package:wlog/core/error/failures.dart';
import 'package:wlog/core/usecase/usecase.dart';
import 'package:wlog/features/auth/domain/repo/auth_repo.dart';

class UserSignup implements Usecase<String, userSignupParams> {
  final AuthRepo authRepo;
  UserSignup({required this.authRepo});

  @override
  Future<Either<Failure, String>> call(userSignupParams params) async {
    return await authRepo.signUp(
        email: params.email, password: params.password, name: params.name);
  }
}

class userSignupParams {
  final String email;
  final String password;
  final String name;

  userSignupParams(
      {required this.email, required this.password, required this.name});
}
