// Google Sign-In Button Widget
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../config/font_profile.dart';

class GoogleSignInButtonEdu extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignInButtonEdu({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50.0),
        side: BorderSide(color: Theme.of(context).colorScheme.primary),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://www.google.com/favicon.ico',
            height: 24,
            width: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Sign Up with Google',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: FontProfile.medium,
            ),
          ),
        ],
      ),
    );
  }
}