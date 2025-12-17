import 'package:flutter/foundation.dart';
import '../api/models/auth_response.dart';
import '../api/models/user.dart';

class AuthState extends ChangeNotifier {
  User? user;
  bool get isAuthenticated => user != null;

  void setSession(AuthResponse res) {
    user = res.user;
    notifyListeners();
  }

  // Use this to set user and notify listeners
  void setUser(User user) {
    this.user = user;
    notifyListeners();
  }

  void logout() {
    user = null;
    notifyListeners();
  }
}
