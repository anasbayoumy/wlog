part of 'app_user_cubit.dart';

@immutable
abstract class AppUserState {}

class AppUserInitial extends AppUserState {}

class IsLoggedIn extends AppUserState {
  final UserEntity user;
  IsLoggedIn({required this.user});
}

class IsNotLoggedIn extends AppUserState {}



// final class AppUserLoading extends AppUserState {}

// final class AppUserLoaded extends AppUserState {
//   final UserEntity user;
// }

