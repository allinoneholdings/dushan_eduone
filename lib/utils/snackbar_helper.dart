import 'package:flutter/material.dart';

class SnackBarHelper {
  static void show(BuildContext context, String message, {bool isError = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: colorScheme.onSecondary),
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: isError ? colorScheme.error : colorScheme.primary,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}