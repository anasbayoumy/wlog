import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wlog/core/error/exceptions.dart';

abstract interface class AuthRemoteDataSource {
  Future<String> signUp({
    required String email,
    required String password,
    required String name,
  });
  Future<String> logIn({
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImp implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImp({required this.supabaseClient});

  @override
  Future<String> logIn({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<String> signUp(
      {required String email,
      required String password,
      required String name}) async {
    try {
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw ServerException(message: 'All fields are required');
      }

      if (password.length < 6) {
        throw ServerException(
            message: 'Password must be at least 6 characters');
      }

      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
        },
      );

      if (response.user == null) {
        throw ServerException(message: 'Failed to create user');
      }

      if (response.session == null) {
        throw ServerException(
            message: 'Email verification required. Please check your email.');
      }

      return response.user!.id;
    } on ServerException {
      rethrow;
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(
          message: 'An unexpected error occurred: ${e.toString()}');
    }
  }
}
