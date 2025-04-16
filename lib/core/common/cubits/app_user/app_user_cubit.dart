import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wlog/core/common/entities/user.dart';
// import 'package:wlog/core/usecase/usecase.dart';
// import 'package:wlog/features/auth/domain/usecases/current_user.dart';
// import 'package:wlog/initDependencies.dart';

part 'app_user_state.dart';

class AppUserCubit extends Cubit<AppUserState> {
  AppUserCubit() : super(AppUserInitial()) {
    // getAppUser();
  }

  void updateUser(UserEntity? user) {
    if (user == null) {
      emit(IsNotLoggedIn());
    } else {
      emit(IsLoggedIn(user: user));
    }
  }

  // Future<void> getAppUser() async {
  //   try {
  //     final result =
  //         await serviceLocator<CurrentUserUseCase>().call(NoParams());
  //     result.fold(
  //       (failure) {
  //         print('Failed to get current user: ${failure.message}');
  //         emit(IsNotLoggedIn());
  //       },
  //       (user) {
  //         if (user.id.isEmpty) {
  //           print('Invalid user data: missing id');
  //           emit(IsNotLoggedIn());
  //         } else {
  //           print('Successfully got current user: ${user.email}');
  //           emit(IsLoggedIn(user: user));
  //         }
  //       },
  //     );
  //   } catch (e) {
  //     print('Error getting current user: $e');
  //     emit(IsNotLoggedIn());
  //   }
  // }
}
