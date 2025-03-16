import 'package:flutter/material.dart';

import '../widgets/custom_text_field.dart';
import '../services/auth.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  void switchAuthMethod() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLogin) {
      return _LoginScreen(switchAuthMethod);
    } else {
      return _SignUpScreen(switchAuthMethod);
    }
  }
}

class _LoginScreen extends StatefulWidget {
  final VoidCallback switchMethod;

  const _LoginScreen(this.switchMethod);

  @override
  State<_LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreen> {
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
              onPressed: widget.switchMethod,
              child: Text('Create an Account'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignUpScreen extends StatefulWidget {
  final VoidCallback switchMethod;

  const _SignUpScreen(this.switchMethod);

  @override
  State<_SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<_SignUpScreen> {
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
              onPressed: widget.switchMethod,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
