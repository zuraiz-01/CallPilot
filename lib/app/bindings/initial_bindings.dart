import 'package:get/get.dart';

import '../../core/config/supabase_service.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/repo/auth_repository.dart';
import '../../core/config/twilio_voice_service.dart';
import '../../features/dialer/controllers/dialer_controller.dart';
import '../../features/history/controllers/history_controller.dart';
import '../../features/history/repo/history_repository.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<SupabaseService>(SupabaseService.instance, permanent: true);
    Get.put<TwilioVoiceService>(TwilioVoiceService(), permanent: true);

    Get.put<AuthRepository>(
      AuthRepository(Get.find<SupabaseService>()),
      permanent: true,
    );
    Get.put<HistoryRepository>(
      HistoryRepository(Get.find<SupabaseService>()),
      permanent: true,
    );

    Get.put<AuthController>(
      AuthController(Get.find<AuthRepository>()),
      permanent: true,
    );
    Get.lazyPut<DialerController>(() => DialerController(), fenix: true);
    Get.lazyPut<HistoryController>(() => HistoryController(
          Get.find<HistoryRepository>(),
          Get.find<SupabaseService>(),
        ));
  }
}
