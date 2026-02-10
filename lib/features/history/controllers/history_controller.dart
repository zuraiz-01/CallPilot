import 'package:get/get.dart';

import '../repo/history_repository.dart';

class HistoryController extends GetxController {
  HistoryController(this._repository);

  final HistoryRepository _repository;
  final items = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  void loadHistory() {
    items.assignAll(_repository.getAll());
  }

  void clearHistory() {
    _repository.clear();
    items.clear();
  }
}
