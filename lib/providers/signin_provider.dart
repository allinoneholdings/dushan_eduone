import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../services/auth_service.dart';
import '../utils/snackbar_helper.dart';

class SigninProvider extends ChangeNotifier {
  bool _isSpinKitLoaded = false;
  final AuthService _authService = AuthService();

  bool get isSpinKitLoaded => _isSpinKitLoaded;

  Future<void> handleSignIn({required String email, required String password}) async {
      _isSpinKitLoaded = true;
      notifyListeners();

    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password
      );


    }finally {
        _isSpinKitLoaded = false;
        notifyListeners();

    }

  }
}

