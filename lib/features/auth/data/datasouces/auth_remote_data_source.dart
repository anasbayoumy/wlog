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
    // TODO: implement logIn
    throw UnimplementedError();
  }

  @override
  Future<String> signUp(
      {required String email,
      required String password,
      required String name}) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
        },
      );
      if (response.user == null) {
        throw ServerException(message: 'User not found');
      }
      return response.user!.id;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
