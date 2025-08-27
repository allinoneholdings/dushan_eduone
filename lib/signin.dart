import 'package:edu_one/utils/snackbar_helper.dart';
import 'package:edu_one/widgets/custom_filled_button.dart';
import 'package:edu_one/widgets/custom_text.dart';
import 'package:edu_one/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';


class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSpinKitLoaded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: textTheme.headlineLarge, // Use the base style from your theme
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
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
                        onTap: () =>  SnackBarHelper.show(
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
                      onPressed: () {
                        if (_formKey.currentState?.validate() == true) {
                          setState(() {
                            _isSpinKitLoaded = true;
                          });
                        }
                      },
                      text: 'Sign In',
                    ),
                    const SizedBox(height: 24.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don’t have an account? ",
                          style: textTheme.labelSmall!.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // Navigator.push...
                          },
                          child: Text(
                            "Sign Up",
                            style: textTheme.labelSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary, // Using primary color for a call to action
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
                color: colorScheme.surface.withOpacity(0.7),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}