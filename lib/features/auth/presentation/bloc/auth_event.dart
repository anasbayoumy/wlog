part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String? username;

  SignUpEvent({
    required this.email,
    required this.password,
    required this.name,
    this.username,
  });
}
