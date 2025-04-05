import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wlog/core/error/exceptions.dart';
import 'package:wlog/features/auth/domain/usecases/user_signUp.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignup _userSignup;

  AuthBloc({
    required UserSignup userSignup,
  })  : _userSignup = userSignup,
        super(AuthInitial()) {
    on<SignUpEvent>((event, emit) async {
      try {
        emit(AuthLoading());
        final res = await _userSignup(userSignupParams(
          email: event.email,
          password: event.password,
          name: event.name,
        ));
        res.fold(
          (failure) => emit(AuthFailure(failure.message)),
          (success) => emit(AuthSuccess()),
        );
      } on ServerException catch (e) {
        emit(AuthFailure(e.message));
      } catch (e) {
        emit(AuthFailure('An unexpected error occurred: ${e.toString()}'));
      }
    });
  }
}
