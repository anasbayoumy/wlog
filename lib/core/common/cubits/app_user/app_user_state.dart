part of 'app_user_cubit.dart';

@immutable
sealed class AppUserState {}

final class AppUserInitial extends AppUserState {}

final class IsLoggedIn extends AppUserState {
  final UserEntity user;
  IsLoggedIn({required this.user});
}

final class IsNotLoggedIn extends AppUserState {}



// final class AppUserLoading extends AppUserState {}

// final class AppUserLoaded extends AppUserState {
//   final UserEntity user;
// }

