import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../controllers/history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            onPressed: () => Get.offNamed(AppRoutes.dialer),
            icon: const Icon(Icons.dialpad),
            tooltip: 'Dialer',
          ),
          IconButton(
            onPressed: controller.loadHistory,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(
            () {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value != null) {
                return Center(
                  child: Text(
                    controller.errorMessage.value!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                );
              }

              if (controller.logs.isEmpty) {
                return Center(
                  child: Text(
                    'No calls yet',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }

              return ListView.separated(
                itemCount: controller.logs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final log = controller.logs[index];
                  return Card(
                    child: ListTile(
                      title: Text(log.toNumber),
                      subtitle: Text(
                        '${log.status} · ${controller.formatDuration(log.durationSec)}',
                      ),
                      trailing: Text(
                        controller.formatDate(log.startedAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
