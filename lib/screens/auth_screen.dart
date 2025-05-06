import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Sign Up'),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _isLogin
            ? _LoginScreen(
                key: const ValueKey('login'),
                switchMethod: switchAuthMethod,
              )
            : _SignUpScreen(
                key: const ValueKey('signup'),
                switchMethod: switchAuthMethod,
              ),
      ),
    );
  }
}

class _LoginScreen extends StatefulWidget {
  final VoidCallback switchMethod;

  const _LoginScreen({Key? key, required this.switchMethod});

  @override
  State<_LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password.')),
      );
      return;
    }

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
    setState(() => isLoading = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final auth = AuthServices();
    final errorMessage = await auth.signInWithGoogle();

    if (errorMessage != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [
        FadeEffect(),
        SlideEffect(begin: Offset(0, 0.1), end: Offset.zero)
      ],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome Back!',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ).animate(effects: const [FadeEffect(), SlideEffect()]),

            const SizedBox(height: 24),

            // Standard TextField using theme's InputDecorationTheme
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ).animate(effects: const [
              FadeEffect(),
              SlideEffect(delay: Duration(milliseconds: 100))
            ]),

            const SizedBox(height: 16),

            // Standard TextField using theme's InputDecorationTheme
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
            ).animate(effects: const [
              FadeEffect(),
              SlideEffect(delay: Duration(milliseconds: 200))
            ]),

            const SizedBox(height: 24),

            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Sign In'),
                  ).animate(effects: const [
                    FadeEffect(),
                    SlideEffect(delay: Duration(milliseconds: 300))
                  ]),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: isLoading ? null : _signInWithGoogle,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 8),
                  Text('Sign In with Google'),
                ],
              ),
            ).animate(effects: const [
              FadeEffect(),
              SlideEffect(delay: Duration(milliseconds: 400))
            ]),

            const SizedBox(height: 24),

            TextButton(
              onPressed: isLoading ? null : widget.switchMethod,
              child: const Text('Create an Account'),
            ).animate(effects: const [
              FadeEffect(),
              SlideEffect(delay: Duration(milliseconds: 500))
            ]),
          ],
        ),
      ),
    );
  }
}

class _SignUpScreen extends StatefulWidget {
  final VoidCallback switchMethod;

  const _SignUpScreen({Key? key, required this.switchMethod});

  @override
  State<_SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<_SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

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
    return Animate(
      effects: const [
        FadeEffect(),
        SlideEffect(begin: Offset(0, 0.1), end: Offset.zero)
      ],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create Account',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ).animate(effects: const [FadeEffect(), SlideEffect()]),

            const SizedBox(height: 24),

            // Standard TextField using theme's InputDecorationTheme
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ).animate(effects: const [
              FadeEffect(),
              SlideEffect(delay: Duration(milliseconds: 100))
            ]),

            const SizedBox(height: 16),

            // Standard TextField using theme's InputDecorationTheme
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              keyboardType: TextInputType.visiblePassword,
            ).animate(effects: const [
              FadeEffect(),
              SlideEffect(delay: Duration(milliseconds: 200))
            ]),

            const SizedBox(height: 16),

            // Standard TextField using theme's InputDecorationTheme
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              keyboardType: TextInputType.visiblePassword,
            ).animate(effects: const [
              FadeEffect(),
              SlideEffect(delay: Duration(milliseconds: 300))
            ]),

            const SizedBox(height: 24),

            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _signUp,
                    child: const Text('Sign Up'),
                  ).animate(effects: const [
                    FadeEffect(),
                    SlideEffect(delay: Duration(milliseconds: 400))
                  ]),

            const SizedBox(height: 24),

            TextButton(
              onPressed: isLoading ? null : widget.switchMethod,
              child: const Text('Login'),
            ).animate(effects: const [
              FadeEffect(),
              SlideEffect(delay: Duration(milliseconds: 500))
            ]),
          ],
        ),
      ),
    );
  }
}
