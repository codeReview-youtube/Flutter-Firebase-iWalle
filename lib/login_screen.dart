import 'package:flutter/material.dart';
import 'package:iwalle/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 300,
              ),
              TextField(
                controller: _emailController,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  helperText: 'Please enter a valid email address',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _passwordController,
                autocorrect: false,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  helperText:
                      'Please enter a password with at least 6 characters',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () async {
                  // basic validation
                  if (_emailController.text.isNotEmpty &&
                      _passwordController.text.isNotEmpty) {
                    await authService.signOrCreateUser(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );
                  }
                },
                child: const Row(
                  children: [
                    Text('Sign in'),
                    Icon(Icons.login),
                  ],
                ),
              ),
              const SizedBox(
                height: 100,
              ),
              TextButton(
                onPressed: authService.signInAnonymous,
                child: const Text('Sign in anonymously'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
