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

  // ValueNotifier for password visibility
  final ValueNotifier<bool> _isPasswordVisible = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _isPasswordVisible.dispose();
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
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ).animate(effects: const [
              FadeEffect(),
              SlideEffect(delay: Duration(milliseconds: 100))
            ]),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: _isPasswordVisible,
              builder: (context, isPasswordVisible, child) {
                return TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                      onPressed: () {
                        _isPasswordVisible.value = !isPasswordVisible;
                      },
                    ),
                  ),
                  obscureText: !isPasswordVisible,
                  keyboardType: TextInputType.visiblePassword,
                ).animate(effects: const [
                  FadeEffect(),
                  SlideEffect(delay: Duration(milliseconds: 200))
                ]);
              },
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: isLoading ? null : _login,
              child: isLoading
                  ? const Center(
                      child: SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : const Text('Login'),
            ).animate(
              effects: const [
                FadeEffect(),
                SlideEffect(delay: Duration(milliseconds: 300))
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Don\'t have an account?'),
                const SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(0),
                  ),
                  onPressed: isLoading ? null : widget.switchMethod,
                  child: const Text('Create an Account'),
                ),
              ],
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

  // ValueNotifiers for password visibility
  final ValueNotifier<bool> _isPasswordVisible = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isConfirmPasswordVisible =
      ValueNotifier<bool>(false);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _isPasswordVisible.dispose();
    _isConfirmPasswordVisible.dispose();
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
          crossAxisAlignment: CrossAxisAlignment.center,
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

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ).animate(effects: const [
              FadeEffect(),
              SlideEffect(delay: Duration(milliseconds: 100))
            ]),

            const SizedBox(height: 16),

            // Password TextField with visibility toggle
            ValueListenableBuilder<bool>(
              valueListenable: _isPasswordVisible,
              builder: (context, isPasswordVisible, child) {
                return TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                        onPressed: () {
                          _isPasswordVisible.value = !isPasswordVisible;
                        }),
                  ),
                  obscureText: !isPasswordVisible,
                  keyboardType: TextInputType.visiblePassword,
                ).animate(effects: const [
                  FadeEffect(),
                  SlideEffect(delay: Duration(milliseconds: 200))
                ]);
              },
            ),
            const SizedBox(height: 16),

            // Confirm Password TextField with visibility toggle
            ValueListenableBuilder<bool>(
              valueListenable: _isConfirmPasswordVisible,
              builder: (context, isConfirmPasswordVisible, child) {
                return TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                      onPressed: () {
                        _isConfirmPasswordVisible.value =
                            !isConfirmPasswordVisible;
                      },
                    ),
                  ),
                  obscureText: !isConfirmPasswordVisible,
                  keyboardType: TextInputType.visiblePassword,
                ).animate(effects: const [
                  FadeEffect(),
                  SlideEffect(delay: Duration(milliseconds: 300))
                ]);
              },
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _signUp,
                child: isLoading
                    ? const Center(
                        child: SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : const Text('Sign Up'),
              ).animate(
                effects: const [
                  FadeEffect(),
                  SlideEffect(delay: Duration(milliseconds: 400))
                ],
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const SizedBox(height: 8),
                const Text('Already have an account?'),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(0),
                  ),
                  onPressed: isLoading ? null : widget.switchMethod,
                  child: const Text('Login'),
                ),
              ],
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
