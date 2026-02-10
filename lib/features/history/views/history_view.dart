import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
            onPressed: controller.clearHistory,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(
            () {
              if (controller.items.isEmpty) {
                return Center(
                  child: Text(
                    'No calls yet',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }
              return ListView.separated(
                itemCount: controller.items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final number = controller.items[index];
                  return Card(
                    child: ListTile(
                      title: Text(number),
                      subtitle: const Text('Completed'),
                      trailing: const Icon(Icons.call_made),
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
