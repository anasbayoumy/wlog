import 'package:fpdart/fpdart.dart';
import 'package:wlog/core/error/failures.dart';
import 'package:wlog/core/usecase/usecase.dart';
import 'package:wlog/core/common/entities/user.dart';
import 'package:wlog/features/auth/domain/repo/auth_repo.dart';

class CurrentUserUseCase implements Usecase<UserEntity, NoParams> {
  final AuthRepo authRepo;

  CurrentUserUseCase({required this.authRepo});

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return await authRepo.getCurrentUser();
  }
}
