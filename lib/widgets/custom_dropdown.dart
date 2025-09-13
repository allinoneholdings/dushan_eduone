// Role Dropdown Widget
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'custom_text.dart';

class CustomDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator validator;

  const CustomDropdown({
    required this.value,
    required this.onChanged,
    required this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        label: CustomText(text: 'Role'),
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      items:const [
        DropdownMenuItem(value: 'Student', child: Text('Student')),
        DropdownMenuItem(value: 'Staff', child: Text('Staff')),
      ],
      onChanged: onChanged,
      validator: validator,
    );
  }
}
