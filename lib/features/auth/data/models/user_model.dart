import 'package:wlog/features/auth/domain/entities/user.dart';

class UserModel extends UserEntity {
  UserModel({required super.id, required super.name, required super.email});

  factory UserModel.fromJson(Map<String, dynamic> map) {
    print('Converting user data: $map'); // Debug log

    // Supabase stores user metadata in a separate field
    final userMetadata = map['user_metadata'] as Map<String, dynamic>? ?? {};

    final id = map['id']?.toString() ?? '';
    final name =
        userMetadata['name']?.toString() ?? map['name']?.toString() ?? '';
    final email = map['email']?.toString() ?? '';

    if (id.isEmpty || name.isEmpty || email.isEmpty) {
      throw Exception(
          'Invalid user data: missing required fields. id: $id, name: $name, email: $email');
    }

    return UserModel(
      id: id,
      name: name,
      email: email,
    );
  }
}
