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
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        print('No current user found');
        return null;
      }

      final userData = user.toJson();
      print('Raw user data: $userData'); // Debug log

      final userMetadata =
          userData['user_metadata'] as Map<String, dynamic>? ?? {};
      final identityData = (userData['identities'] as List?)
              ?.firstOrNull?['identity_data'] as Map<String, dynamic>? ??
          {};

      // Get email from user data or metadata
      final email = userData['email']?.toString() ??
          userMetadata['email']?.toString() ??
          identityData['email']?.toString() ??
          '';

      // Get name from metadata or user data
      final name = userMetadata['name']?.toString() ??
          userData['name']?.toString() ??
          identityData['name']?.toString() ??
          'User';

      // Create a new map with the required fields
      final processedData = {
        'id': userData['id']?.toString() ?? '',
        'email': email,
        'name': name,
      };

      print('Processed user data: $processedData'); // Debug log
      return UserModel.fromJson(processedData);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
}
