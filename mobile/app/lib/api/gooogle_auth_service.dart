import 'package:google_sign_in/google_sign_in.dart';
import 'auth_service.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<bool> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return false;

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception("Google ID token missing");
    }

    return AuthService().loginWithGoogle(idToken);
  }
}
