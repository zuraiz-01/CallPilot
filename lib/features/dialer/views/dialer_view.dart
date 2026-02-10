import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/dialer_controller.dart';

class DialerView extends GetView<DialerController> {
  const DialerView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '0', ''];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dialer'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.history),
            icon: const Icon(Icons.history),
            tooltip: 'History',
          ),
          IconButton(
            onPressed: authController.logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _DialerDisplay(controller: controller),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: keys.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final keyValue = keys[index];
                  if (keyValue.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return _DialerKeyButton(
                    label: keyValue,
                    onTap: () => controller.appendDigit(keyValue),
                  );
                },
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.clear,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (controller.validateNumber()) {
                          Get.toNamed(
                            AppRoutes.call,
                            arguments: controller.phoneNumber.value,
                          );
                        }
                      },
                      icon: const Icon(Icons.call),
                      label: const Text('Call'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialerDisplay extends StatelessWidget {
  const _DialerDisplay({required this.controller});

  final DialerController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Obx(
                () => Text(
                  controller.phoneNumber.value.isEmpty
                      ? 'Enter number'
                      : controller.phoneNumber.value,
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            IconButton(
              onPressed: controller.backspace,
              icon: const Icon(Icons.backspace_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialerKeyButton extends StatelessWidget {
  const _DialerKeyButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
