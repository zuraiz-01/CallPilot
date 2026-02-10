import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/bindings/initial_bindings.dart';
import 'app/routes/app_routes.dart';
import 'core/config/app_theme.dart';
import 'core/config/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.instance.init();
  runApp(const CallPilotApp());
}

class CallPilotApp extends StatelessWidget {
  const CallPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CallPilot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialBinding: InitialBindings(),
      initialRoute: AppRoutes.initial,
      getPages: AppRoutes.pages,
    );
  }
}
