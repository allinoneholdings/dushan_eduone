import 'package:edu_one/screens/admin/admin_navigation.dart';
import 'package:edu_one/signup.dart';
import 'package:edu_one/utils/snackbar_helper.dart';
import 'package:edu_one/widgets/custom_filled_button.dart';
import 'package:edu_one/widgets/custom_text.dart';
import 'package:edu_one/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edu_one/services/auth_service.dart'; // Import the AuthService class

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService =
      AuthService(); // Create an instance of AuthService
  bool _isSpinKitLoaded = false;

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
                      'Welcome Back!',
                      style: textTheme.headlineLarge!.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Sign in to continue your learning journey.',
                      style: textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48.0),
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
                    const SizedBox(height: 12.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap:
                            () => SnackBarHelper.show(
                              context,
                              'Coming soon, Please contact the administrator',
                              isError: true,
                            ),
                        child: Text(
                          "Forgot password?",
                          style: textTheme.labelSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48.0),
                    CustomFilledButton(
                      onPressed: _handleSignIn,
                      text: 'Sign In',
                    ),
                    const SizedBox(height: 24.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don’t have an account? ",
                          style: textTheme.labelLarge!.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUp(),
                              ),
                            );
                          },
                          child: Text(
                            "Sign Up",
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
            if (_isSpinKitLoaded)
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

  // New method to handle the sign-in process
  Future<void> _handleSignIn() async {
    if (_formKey.currentState?.validate() == true) {
      setState(() {
        _isSpinKitLoaded = true;
      });

      try {
        await _authService.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          SnackBarHelper.show(context, 'Signed in successfully!');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => AdminNavigation()),
            (Route<dynamic> route) => false, // Remove all previous routes
          );
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          message = 'Wrong password provided for that user.';
        } else {
          message = 'Invalid email or password. Please try again.';
        }
        if (mounted) {
          SnackBarHelper.show(context, message, isError: true);
        }
      } catch (e) {
        debugPrint('Error during sign in: $e');
        if (mounted) {
          SnackBarHelper.show(
            context,
            'An unexpected error occurred. Please try again.',
            isError: true,
          );
        }
      } finally {
        setState(() {
          _isSpinKitLoaded = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
