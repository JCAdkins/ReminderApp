class LoginResponse {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json["access_token"],
      refreshToken: json["refresh_token"],
      tokenType: json["token_type"] ?? "bearer",
    );
  }
}
