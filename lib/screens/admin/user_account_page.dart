import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edu_one/signin.dart'; // Import the sign-in page to navigate to

class UserAccountPage extends StatelessWidget {
  const UserAccountPage({super.key});

  // A method to handle the logout action
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // After signing out, navigate back to the sign-in page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignIn()),
        (Route<dynamic> route) => false, // Remove all previous routes
      );
    } catch (e) {
      // Handle any potential errors during sign-out
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Account',
          style: textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 16.0),
        ],
      ),
      body:
          user == null
              ? const Center(
                child: Text(
                  'User not logged in.',
                  style: TextStyle(fontSize: 18),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: colorScheme.secondaryContainer,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Display User's Name
                    if (user.displayName != null &&
                        user.displayName!.isNotEmpty)
                      Text(
                        user.displayName!,
                        style: textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 8),
                    // Display User's Email
                    Text(
                      user.email ?? 'No email available',
                      style: textTheme.bodyLarge!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Additional Account Details Section (You can add more here)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Account Information',
                        style: textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailCard(
                      context,
                      title: 'Authentication Provider',
                      value:
                          user.providerData.isNotEmpty
                              ? user.providerData[0].providerId
                              : 'Unknown',
                      icon: Icons.fingerprint,
                    ),
                    _buildDetailCard(
                      context,
                      title: 'Joined Since',
                      value:
                          user.metadata.creationTime != null
                              ? user.metadata.creationTime!.toString().split(
                                ' ',
                              )[0]
                              : 'N/A',
                      icon: Icons.calendar_today_outlined,
                    ),
                  ],
                ),
              ),
    );
  }

  // Helper method to build a detail card
  Widget _buildDetailCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 0,
      color: colorScheme.surfaceContainer,
      child: ListTile(
        leading: Icon(icon, color: colorScheme.onSurfaceVariant),
        title: Text(
          title,
          style: textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Text(value, style: textTheme.bodyLarge),
      ),
    );
  }
}
