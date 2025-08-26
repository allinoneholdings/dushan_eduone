import 'package:edu_one/widgets/custom_filled_button.dart';
import 'package:edu_one/widgets/custom_text.dart';
import 'package:edu_one/widgets/custom_text_form_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'config/font_profile.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSpinKitLoaded = false;
  final _formKey = GlobalKey<FormState>();

  _SignInState();
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to EduOne'), centerTitle: true),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(20.0),
              padding: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withAlpha(95),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //_buildHeadline('Login'),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(text: 'Email'),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),

                            child: CustomTextFormField(
                              hint: 'eduonemail@email.com',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required.';
                                }
                                final emailRegex = RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+$',
                                );
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Invalid email format.';
                                }
                                return null;
                              },
                              textController: _emailController,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(text: 'Password'),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),

                            child: CustomTextFormField(
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
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 50.0, bottom: 70.0),
                        child: CustomFilledButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() == true) {
                              setState(() {
                                _isSpinKitLoaded = true;
                              });
                            }
                          },
                          text: 'Sign in',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: InkWell(
                          onTap: () {
                            _showSnackBar(
                              'Coming soon, Please contact the administrator',
                              true,
                            );
                          },
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: FontProfile.small,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don’t have an account? ",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: FontProfile.small,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => const Signup()));
                              },
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: FontProfile.small,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _isSpinKitLoaded
              ? Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 100.0),
                  child: CircularProgressIndicator(color: colorScheme.primary),
                ),
              )
              : Container(),
        ],
      ),
    );
  }

  // void navigate(User? user) {
  //   if (user != null) {
  //     Navigator.pushAndRemoveUntil(
  //       context,
  //       MaterialPageRoute(builder: (context) => IndexPage()),
  //           (Route<dynamic> route) => false, // Remove all routes
  //     );
  //   } else {
  //     _showSnackBar('Login failed. Email or password is wrong.', true);
  //   }
  // }

  void _showSnackBar(String msg, bool isError) {
    final _colorScheme = Theme.of(context).colorScheme;
    final snackBar = SnackBar(
      content: Text(msg, style: TextStyle(color: _colorScheme.onSecondary)),
      duration: const Duration(seconds: 3),
      backgroundColor: isError ? _colorScheme.secondary : _colorScheme.primary,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
