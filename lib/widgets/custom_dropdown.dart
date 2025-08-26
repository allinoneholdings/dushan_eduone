// Role Dropdown Widget
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'custom_text.dart';

class CustomDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({required this.value, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        label: CustomText(
          text: 'Role',
        ),
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      items: ['Student', 'Staff'].map((String role) {
        return DropdownMenuItem<String>(
          value: role,
          child: Text(role),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a role.';
        }
        return null;
      },
    );
  }
}