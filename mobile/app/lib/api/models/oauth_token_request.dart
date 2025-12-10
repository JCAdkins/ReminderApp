class OAuthTokenRequest {
  final String idToken;

  OAuthTokenRequest({required this.idToken});

  Map<String, dynamic> toJson() => {
        "id_token": idToken,
      };
}
