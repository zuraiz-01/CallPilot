import 'package:get/get.dart';

import '../../core/config/supabase_service.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/repo/auth_repository.dart';
import '../../core/config/twilio_voice_service.dart';
import '../../features/call/controllers/call_controller.dart';
import '../../features/dialer/controllers/dialer_controller.dart';
import '../../features/history/controllers/history_controller.dart';
import '../../features/history/repo/history_repository.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<SupabaseService>(SupabaseService.instance, permanent: true);
    Get.put<TwilioVoiceService>(TwilioVoiceService(), permanent: true);

    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find<SupabaseService>()));
    Get.lazyPut<HistoryRepository>(() => HistoryRepository());

    Get.lazyPut<AuthController>(() => AuthController(Get.find<AuthRepository>()));
    Get.lazyPut<DialerController>(() => DialerController());
    Get.lazyPut<CallController>(() => CallController(
          Get.find<TwilioVoiceService>(),
          Get.find<SupabaseService>(),
          Get.find<HistoryRepository>(),
        ));
    Get.lazyPut<HistoryController>(() => HistoryController(Get.find<HistoryRepository>()));
  }
}
