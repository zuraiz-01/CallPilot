import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/call_controller.dart';

class CallView extends GetView<CallController> {
  const CallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Obx(
                () => Text(
                  _statusLabel(controller.status.value),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => Text(
                  controller.phoneNumber.value.isEmpty
                      ? 'Unknown'
                      : controller.phoneNumber.value,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => Text(
                  controller.formattedDuration(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Text(
                  controller.status.value == CallStatus.connected
                      ? 'Encrypted connection'
                      : 'Connecting securely',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.mic_off,
                      label: 'Mute',
                      isActive: controller.isMuted,
                      onTap: controller.toggleMute,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.volume_up,
                      label: 'Speaker',
                      isActive: controller.isSpeakerOn,
                      onTap: controller.toggleSpeaker,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.endCall,
                  icon: const Icon(Icons.call_end),
                  label: const Text('End Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(CallStatus status) {
    switch (status) {
      case CallStatus.idle:
        return 'Preparing call';
      case CallStatus.calling:
        return 'Calling';
      case CallStatus.connected:
        return 'Connected';
      case CallStatus.ended:
        return 'Call ended';
      case CallStatus.error:
        return 'Call failed';
    }
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final RxBool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(
            color: isActive.value
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive.value
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}
