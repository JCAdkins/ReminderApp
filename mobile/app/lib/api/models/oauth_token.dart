class OAuthToken {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final DateTime? expiresAt;

  OAuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    this.expiresAt,
  });

  factory OAuthToken.fromJson(Map<String, dynamic> json) {
    return OAuthToken(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'],
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
    );
  }
}
