import 'package:edu_one/services/auth_service.dart';
import 'package:flutter/cupertino.dart';

class SignupProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isSpinKitLoaded = false;

  bool get isSpinKitLoaded => _isSpinKitLoaded;

  Future<void> handleSignUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    _isSpinKitLoaded = true;
    notifyListeners();

    try {
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
      );
    } finally {
      _isSpinKitLoaded = false;
      notifyListeners();
    }
  }
}
