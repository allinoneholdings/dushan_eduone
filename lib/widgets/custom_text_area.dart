import 'package:flutter/material.dart';

class CustomTextFormArea extends StatelessWidget {
  final TextEditingController textController;
  final String hint;
  final bool obscureText;
  final FormFieldValidator validator;
  final TextInputType keyboardType;
  final int maxLines;

  const CustomTextFormArea({
    super.key,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    required this.hint,
    required this.validator,
    required this.textController, required this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 2.0,
            style: BorderStyle.solid,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 2.0,
            style: BorderStyle.solid,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 2.0,
            style: BorderStyle.solid,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 2.0,
            style: BorderStyle.solid,
          ),
        ),
        hintText: hint,
      ),
      obscureText: obscureText,
      obscuringCharacter: "*",
      validator: validator,
      keyboardType: keyboardType,
      maxLines: 5, // This property allows multiple lines of text, up to a max of 5
    );
  }
}
