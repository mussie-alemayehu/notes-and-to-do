import 'package:flutter/material.dart';

import './signup_screen.dart';
import '../widgets/custom_text_field.dart';
import '../providers/auth.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  void _login() async {
    setState(() => isLoading = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final auth = AuthServices();
    final errorMessage = await auth.signIn(
      _emailController.text,
      _passwordController.text,
    );

    if (errorMessage != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
    setState(() => isLoading = false);
  }

  void _signInWithGoogle() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final auth = AuthServices();
    final errorMessage = await auth.signInWithGoogle();

    if (errorMessage != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              controller: _emailController,
              label: 'Email',
            ),
            CustomTextField(
              controller: _passwordController,
              label: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 16),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondary,
                    ),
                    child: Text('Sign In'),
                  ),
            ElevatedButton(
              onPressed: _signInWithGoogle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
              child: Text('Sign In with Google'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  SignUpScreen.routeName,
                );
              },
              child: Text('Create an Account'),
            ),
          ],
        ),
      ),
    );
  }
}
