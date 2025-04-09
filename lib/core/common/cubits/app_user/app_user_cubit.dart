import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wlog/core/common/entities/user.dart';
import 'package:wlog/core/usecase/usecase.dart';
import 'package:wlog/features/auth/domain/usecases/current_user.dart';
import 'package:wlog/initDependencies.dart';

part 'app_user_state.dart';

class AppUserCubit extends Cubit<AppUserState> {
  AppUserCubit() : super(AppUserInitial());

  void updateUser(UserEntity? user) {
    if (user == null) {
      emit(AppUserInitial());
    } else {
      emit(IsLoggedIn(user: user));
    }
  }

  void getAppUser() {
    final user = serviceLocator<CurrentUserUseCase>().call(NoParams());
  }
}
