// lib/features/1_auth/domain/entities/user_entity.dart

class UserEntity {
  final String username;
  final String email;
  final List<String> roles;

  const UserEntity({
    required this.username,
    required this.email,
    required this.roles,
  });
}
