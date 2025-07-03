// lib/features/1_auth/data/models/jwt_response_model.dart

class JwtResponseModel {
  final String token;
  final String tokenType;
  final String username;
  final List<String> roles;

  JwtResponseModel({
    required this.token,
    required this.tokenType,
    required this.username,
    required this.roles,
  });

  factory JwtResponseModel.fromJson(Map<String, dynamic> json) {
    return JwtResponseModel(
      token: json['token'],
      tokenType: json['tokenType'],
      username: json['username'],
      roles: List<String>.from(json['roles']),
    );
  }
}
