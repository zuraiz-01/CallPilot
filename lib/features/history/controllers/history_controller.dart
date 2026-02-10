import 'package:get/get.dart';

import '../../../core/config/supabase_service.dart';
import '../models/call_log.dart';
import '../repo/history_repository.dart';

class HistoryController extends GetxController {
  HistoryController(this._repository, this._supabaseService);

  final HistoryRepository _repository;
  final SupabaseService _supabaseService;

  final logs = <CallLog>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final userId = _supabaseService.client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      errorMessage.value = 'Missing user session.';
      logs.clear();
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    try {
      final items = await _repository.fetchLogs(userId: userId);
      logs.assignAll(items);
    } catch (error) {
      errorMessage.value = error.toString();
      logs.clear();
    } finally {
      isLoading.value = false;
    }
  }

  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    final minuteStr = minutes.toString().padLeft(2, '0');
    final secondStr = remainder.toString().padLeft(2, '0');
    return '$minuteStr:$secondStr';
  }

  String formatDate(DateTime? value) {
    if (value == null) {
      return '--';
    }
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }
}
