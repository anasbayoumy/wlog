import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wlog/core/error/exceptions.dart';
import 'package:wlog/features/auth/data/models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Session? get currentSession;
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  });
  Future<UserModel> logIn({
    required String email,
    required String password,
  });

  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImp implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImp({required this.supabaseClient});

  @override
  Session? get currentSession => supabaseClient.auth.currentSession;

  @override
  Future<UserModel> logIn(
      {required String email, required String password}) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw ServerException(message: 'Failed to log in');
      }

      return UserModel.fromJson(response.user!.toJson());
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
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

      final userData = response.user!.toJson();
      return UserModel.fromJson(userData);
    } on ServerException {
      rethrow;
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(
          message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final response = await supabaseClient
        .from('profiles')
        .select()
        .eq('id', currentSession!.user.id);
    return UserModel.fromJson(response.first);
  }
}
