import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edu_one/screens/admin/user_account_page.dart';

// Assuming CustomStatusCard is a custom widget in your project.
// We'll add a mock version here for the code to be self-contained.
class CustomStatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color containerColor;

  const CustomStatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.containerColor,
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
            Icon(
              icon,
              size: 32,
              color: colorScheme.onBackground,
            ),
            const SizedBox(height: 12.0),
            Text(
              value,
              style: textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              title,
              style: textTheme.bodySmall!.copyWith(
                color: colorScheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PageAdminDashboard extends StatelessWidget {
  const PageAdminDashboard({super.key});

  // A helper method to build the status cards with real-time data from Firestore.
  Widget _buildStatusCards(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        // StreamBuilder for Total Users
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              final int count = snapshot.data?.docs.length ?? 0;
              return CustomStatusCard(
                title: 'Total Users',
                value: count.toString(),
                icon: Icons.people_alt,
                containerColor: colorScheme.primaryContainer,
              );
            },
          ),
        ),
        const SizedBox(width: 16.0),
        // StreamBuilder for Active Courses
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('courses')
                .where('isActive', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              final int count = snapshot.data?.docs.length ?? 0;
              return CustomStatusCard(
                title: 'Active Courses',
                value: count.toString(),
                icon: Icons.school,
                containerColor: colorScheme.secondaryContainer,
              );
            },
          ),
        ),
        const SizedBox(width: 16.0),
        // StreamBuilder for New Signups (in the last 24 hours)
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('createdAt', isGreaterThan: DateTime.now().subtract(const Duration(days: 1)))
                .snapshots(),
            builder: (context, snapshot) {
              final int count = snapshot.data?.docs.length ?? 0;
              return CustomStatusCard(
                title: 'New Signups',
                value: count.toString(),
                icon: Icons.person_add,
                containerColor: colorScheme.tertiaryContainer,
              );
            },
          ),
        ),
      ],
    );
  }

  // Helper method to build a management card.
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

  // Helper method to build the management grid.
  Widget _buildManagementGrid(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: colorScheme.onSurface),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserAccountPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 16.0),
        ],
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
              // Use StreamBuilder to get the logged-in user's name
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  String userName = 'Admin';
                  if (snapshot.data != null && snapshot.data!.displayName != null) {
                    final fullName = snapshot.data!.displayName!;
                    if (fullName.contains(' ')) {
                      userName = fullName.split(' ')[0];
                    } else {
                      userName = fullName;
                    }
                  }
                  return Text(
                    'Welcome, $userName!',
                    style: textTheme.headlineLarge!.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8.0),
              Text(
                'Here is a quick overview of the system.',
                style: textTheme.bodyMedium!.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32.0),

              // System Status Section (Now with real-time data)
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
}
