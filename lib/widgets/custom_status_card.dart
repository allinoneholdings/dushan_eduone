import 'package:flutter/material.dart';

class CustomStatusCard extends StatelessWidget {
  final VoidCallback? onTap;
  final Color containerColor;
  final IconData icon;
  final String title;
  final String value;



  const CustomStatusCard({
    super.key,
    this.onTap, required this.containerColor, required this.icon, required this.title, required this.value,
  });



  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: textTheme.labelSmall,
            ),
            const SizedBox(height: 4.0),
            Text(
              value,
              style: textTheme.headlineLarge,
            ),
          ],
        ),
      ),
    );
  }
}
