import 'package:flutter/material.dart';
import 'package:notes/screens/login_screen.dart';

import '../providers/auth.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup';

  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  void _signUp() async {
    setState(() => isLoading = true);
    final auth = AuthServices();

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final errorMessage = await auth.signUp(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signUp,
                    child: Text('Sign Up'),
                  ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  LoginScreen.routeName,
                );
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
