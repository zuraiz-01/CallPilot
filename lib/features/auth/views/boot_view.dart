import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class BootView extends StatefulWidget {
  const BootView({super.key});

  @override
  State<BootView> createState() => _BootViewState();
}

class _BootViewState extends State<BootView> {
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthController>();
    _controller.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Checking session...', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
