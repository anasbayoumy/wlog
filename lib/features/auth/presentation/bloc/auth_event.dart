part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;

  SignUpEvent({
    required this.email,
    required this.password,
    required this.name,
  });
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}
