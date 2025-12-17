import './oauth_token.dart';
import './user.dart';

class AuthResponse {
  final OAuthToken tokens;
  final User user;

  AuthResponse({
    required this.tokens,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      tokens: OAuthToken.fromJson(json['tokens']),
      user: User.fromJson(json['user']),
    );
  }
}
