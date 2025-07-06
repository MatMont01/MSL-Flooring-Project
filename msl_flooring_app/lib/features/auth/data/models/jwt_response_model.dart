class JwtResponseModel {
  final String token;
  final String tokenType;
  final String userId; // <-- AÑADE ESTE CAMPO
  final String username;
  final List<String> roles;

  JwtResponseModel({
    required this.token,
    required this.tokenType,
    required this.userId, // <-- AÑADE ESTO
    required this.username,
    required this.roles,
  });

  factory JwtResponseModel.fromJson(Map<String, dynamic> json) {
    return JwtResponseModel(
      token: json['token'],
      tokenType: json['tokenType'],
      userId: json['userId'], // <-- AÑADE ESTO
      username: json['username'],
      roles: List<String>.from(json['roles']),
    );
  }
}