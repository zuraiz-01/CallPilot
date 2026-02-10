import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../controllers/auth_controller.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthController>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create account', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Start managing calls with CallPilot.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 24),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _controller.isLoading.value
                        ? null
                        : () => _controller.signupWithEmailPassword(
                              email: _emailController.text,
                              password: _passwordController.text,
                            ),
                    child: Text(_controller.isLoading.value ? 'Creating...' : 'Create account'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () => Get.offNamed(AppRoutes.login),
                  child: const Text('Already have an account? Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
