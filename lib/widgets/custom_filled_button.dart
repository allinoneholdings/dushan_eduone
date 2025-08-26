import 'package:flutter/material.dart';

import '../config/font_profile.dart';

class CustomFilledButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  const CustomFilledButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(150.0, 50.0),
        maximumSize: const Size(200.0, 50.0),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        textStyle: TextStyle(fontSize: FontProfile.medium),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: const EdgeInsets.only(
          left: 50.0,
          right: 50.0,
          top: 15.0,
          bottom: 15.0,
        ),
      ),
      child: Text(text),
    );
  }
}
