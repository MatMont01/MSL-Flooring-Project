// lib/features/auth/data/models/jwt_response_model.dart

class JwtResponseModel {
  final String token;
  final String tokenType;
  final String userId;
  final String username;
  final List<String> roles;

  JwtResponseModel({
    required this.token,
    required this.tokenType,
    required this.userId,
    required this.username,
    required this.roles,
  });

  factory JwtResponseModel.fromJson(Map<String, dynamic> json) {
    // 👇 REMUEVE los prints de debugging
    // print('🔥 [JwtResponseModel] Raw JSON: $json');
    // print('🔥 [JwtResponseModel] userId field: ${json['userId']}');

    return JwtResponseModel(
      token: json['token'] as String,
      tokenType: json['tokenType'] as String,
      userId: json['userId'] as String,
      // 👈 SIN fallback ahora
      username: json['username'] as String,
      roles: List<String>.from(json['roles'] as List),
    );
  }
}
