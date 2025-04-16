import 'package:wlog/core/common/entities/user.dart';

class UserModel extends UserEntity {
  UserModel({required super.id, required super.name, required super.email});

  factory UserModel.fromJson(Map<String, dynamic> map) {
    print('Converting user data: $map'); // Debug log

    final id = map['id']?.toString() ?? '';
    final name = map['name']?.toString() ?? 'User';
    final email = map['email']?.toString() ?? '';

    if (id.isEmpty) {
      throw Exception('Invalid user data: missing required field "id"');
    }

    return UserModel(
      id: id,
      name: name,
      email: email,
    );
  }
}
