import 'package:get/get.dart';

import '../../features/auth/views/boot_view.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/signup_view.dart';
import '../../features/call/views/call_view.dart';
import '../../features/dialer/views/dialer_view.dart';
import '../../features/history/views/history_view.dart';

class AppRoutes {
  static const boot = '/boot';
  static const login = '/login';
  static const signup = '/signup';
  static const dialer = '/dialer';
  static const call = '/call';
  static const history = '/history';

  static const initial = boot;

  static final pages = <GetPage<dynamic>>[
    GetPage(name: boot, page: () => const BootView()),
    GetPage(name: login, page: () => const LoginView()),
    GetPage(name: signup, page: () => const SignupView()),
    GetPage(name: dialer, page: () => const DialerView()),
    GetPage(name: call, page: () => const CallView()),
    GetPage(name: history, page: () => const HistoryView()),
  ];
}
