import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wlog/core/error/exceptions.dart';
import 'package:wlog/core/usecase/usecase.dart';
import 'package:wlog/features/auth/domain/entities/user.dart';
import 'package:wlog/features/auth/domain/usecases/current_user.dart';
import 'package:wlog/features/auth/domain/usecases/use_login.dart';
import 'package:wlog/features/auth/domain/usecases/user_signUp.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignup _userSignup;
  final UserLogin _userLogin;
  final CurrentUserUseCase _currentUserUseCase;
  AuthBloc({
    required UserLogin userLogin,
    required UserSignup userSignup,
    required CurrentUserUseCase currentUserUseCase,
  })  : _userSignup = userSignup,
        _userLogin = userLogin,
        _currentUserUseCase = currentUserUseCase,
        super(AuthInitial()) {
    on<LoginEvent>(_onAuthLogin);
    on<IsUserLoggedInEvent>(_onIsUserLoggedIn);
    on<SignUpEvent>(_onAuthSignUp);
  }
  void _onAuthSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      final res = await _userSignup(UserSignupParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ));
      res.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
    } on ServerException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  void _onAuthLogin(LoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      final res = await _userLogin(UserLoginParams(
        email: event.email,
        password: event.password,
      ));
      res.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
    } on ServerException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  void _onIsUserLoggedIn(
      IsUserLoggedInEvent event, Emitter<AuthState> emit) async {
    final res = await _currentUserUseCase(NoParams());
    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }
}
