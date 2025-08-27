import 'package:flutter/material.dart';

import '../../widgets/custom_status_card.dart';

class PageAdminDashboard extends StatelessWidget {
  const PageAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: textTheme.headlineLarge,
            children: <TextSpan>[
              TextSpan(
                text: 'Edu',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'One',
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Welcome Section
              Text(
                'Welcome, Admin!',
                style: textTheme.headlineLarge!.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Here is a quick overview of the system.',
                style: textTheme.bodyMedium!.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32.0),

              // System Status Section (Placeholder for dynamic data)
              _buildStatusCards(context),
              const SizedBox(height: 32.0),

              // Management Options Grid
              Text(
                'Management',
                style: textTheme.headlineLarge!.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              _buildManagementGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCards(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Placeholder data for demonstration
    final int totalUsers = 1200;
    final int activeCourses = 45;
    final int newSignups = 5;

    return Row(
      children: [
        CustomStatusCard(
          title: 'Total Users',
          value: totalUsers.toString(),
          icon: Icons.people_alt,
          containerColor: colorScheme.primaryContainer,
        ),

        const SizedBox(width: 16.0),
        CustomStatusCard(
          title: 'Active Courses',
          value: activeCourses.toString(),
          icon: Icons.school,
          containerColor: colorScheme.secondaryContainer,
        ),

        const SizedBox(width: 16.0),
        CustomStatusCard(
          title: 'New Signups',
          value: newSignups.toString(),
          icon: Icons.person_add,
          containerColor: colorScheme.tertiaryContainer,
        ),
      ],
    );
  }

  Widget _buildManagementGrid(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      shrinkWrap: true, // Use this with SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(), // Disables scrolling
      children: [
        _buildManagementCard(
          context,
          'Manage Users',
          'Add, edit, or remove users.',
          Icons.people_outline,
          () {
            // Navigate to Manage Users page
          },
        ),
        _buildManagementCard(
          context,
          'Manage Courses',
          'Create, update, or delete courses.',
          Icons.school_outlined,
          () {
            // Navigate to Manage Courses page
          },
        ),
        _buildManagementCard(
          context,
          'View Analytics',
          'Monitor system performance.',
          Icons.analytics_outlined,
          () {
            // Navigate to Analytics page
          },
        ),
        _buildManagementCard(
          context,
          'System Settings',
          'Configure global app settings.',
          Icons.settings_outlined,
          () {
            // Navigate to Settings page
          },
        ),
      ],
    );
  }

  Widget _buildManagementCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: colorScheme.outlineVariant, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: colorScheme.onSurface),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              description,
              style: textTheme.labelSmall!.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
