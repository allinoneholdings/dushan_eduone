import 'package:flutter/material.dart';

/// A reusable, customizable popup box widget.
///
/// This widget provides a consistent UI for confirmation dialogs,
/// allowing you to pass in a dynamic title, content, and a list of actions (buttons).
class CustomPopupBox extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;

  const CustomPopupBox({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // The shape property is used to define the corner radius of the dialog.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      title: Text(title),
      content: content,
      actions: actions,
    );
  }
}
