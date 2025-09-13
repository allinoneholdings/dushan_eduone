import 'package:edu_one/providers/signup_provider.dart';
import 'package:edu_one/signin.dart';
import 'package:edu_one/utils/snackbar_helper.dart';
import 'package:edu_one/widgets/custom_dropdown.dart';
import 'package:edu_one/widgets/custom_filled_button.dart';
import 'package:edu_one/widgets/custom_text.dart';
import 'package:edu_one/widgets/custom_text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final signupProvider = context.watch<SignupProvider>();

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style:
                textTheme.headlineLarge, // Use the base style from your theme
            children: <TextSpan>[
              TextSpan(
                text: 'Edu',
                style: TextStyle(
                  color: colorScheme.primary, // First color for 'Edu'
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'One',
                style: TextStyle(
                  color: colorScheme.secondary, // Second color for 'One'
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 48.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Create Your Account',
                      style: textTheme.headlineLarge!.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Join our learning community today.',
                      style: textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48.0),
                    CustomText(text: 'Full Name'),
                    const SizedBox(height: 8.0),
                    CustomTextFormField(
                      hint: 'John Doe',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Full name is required.';
                        }
                        return null;
                      },
                      textController: _nameController,
                    ),
                    const SizedBox(height: 16.0),
                    CustomText(text: 'Email Address'),
                    const SizedBox(height: 8.0),
                    CustomTextFormField(
                      hint: 'eduonemail@email.com',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required.';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Invalid email format.';
                        }
                        return null;
                      },
                      textController: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16.0),
                    CustomText(text: 'Password'),
                    const SizedBox(height: 8.0),
                    CustomTextFormField(
                      textController: _passwordController,
                      hint: '********',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required.';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters long.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    CustomText(text: 'Confirm Password'),
                    const SizedBox(height: 8.0),
                    CustomTextFormField(
                      textController: _confirmPasswordController,
                      hint: '********',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password.';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    CustomText(text: 'Account Type'),
                    const SizedBox(height: 8.0),
                    CustomDropdown(
                      value: _selectedRole,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a role.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 48.0),
                    CustomFilledButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() == true) {
                          context
                              .read<SignupProvider>()
                              .handleSignUp(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                                name: _nameController.text.trim(),
                                role:
                                    _selectedRole != null
                                        ? _selectedRole!
                                        : 'Student',
                              )
                              .then((_) {
                                SnackBarHelper.show(
                                  context,
                                  'Account created as $_selectedRole!',
                                );
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignIn(),
                                  ),
                                  (Route<dynamic> route) =>
                                      false, // Remove all previous routes
                                );
                              })
                              .catchError((e) {
                                String message;
                                if (e.code == 'weak-password') {
                                  message =
                                      'The password provided is too weak.';
                                } else if (e.code == 'email-already-in-use') {
                                  message =
                                      'An account already exists for that email.';
                                } else {
                                  message =
                                      'An unexpected error occurred. Please try again.';
                                }
                                if (mounted) {
                                  SnackBarHelper.show(
                                    context,
                                    message,
                                    isError: true,
                                  );
                                }
                              });
                        }
                      },
                      text: 'Create Account',
                    ),
                    const SizedBox(height: 24.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: textTheme.labelLarge!.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        InkWell(
                          onTap:
                              () => Navigator.pop(
                                context,
                              ), // Go back to the sign-in page
                          child: Text(
                            "Sign In",
                            style: textTheme.labelLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (signupProvider.isSpinKitLoaded)
              Container(
                color: colorScheme.surface.withAlpha(200),
                child: Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
