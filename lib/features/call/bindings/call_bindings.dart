import 'package:get/get.dart';

import '../../../core/config/supabase_service.dart';
import '../../../core/config/twilio_voice_service.dart';
import '../../history/repo/history_repository.dart';
import '../controllers/call_controller.dart';

class CallBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<CallController>(CallController(
      Get.find<TwilioVoiceService>(),
      Get.find<SupabaseService>(),
      Get.find<HistoryRepository>(),
    ));
  }
}
