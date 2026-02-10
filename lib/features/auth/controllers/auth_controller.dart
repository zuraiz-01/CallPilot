import 'dart:async';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/routes/app_routes.dart';
import '../repo/auth_repository.dart';

class AuthController extends GetxController {
  AuthController(this._repository);

  final AuthRepository _repository;
  final isLoading = false.obs;
  final session = Rxn<Session>();

  StreamSubscription<AuthState>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    session.value = _repository.currentSession;
    _routeForSession(session.value);
    _authSubscription = _repository.authStateChanges.listen((event) {
      session.value = event.session;
      _routeForSession(event.session);
    });
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  Future<void> signupWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      Get.snackbar('Missing details', 'Email and password are required.');
      return;
    }

    await _runAuthAction(() async {
      await _repository.signUp(email: trimmedEmail, password: password);
    });
  }

  Future<void> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      Get.snackbar('Missing details', 'Email and password are required.');
      return;
    }

    await _runAuthAction(() async {
      await _repository.signIn(email: trimmedEmail, password: password);
    });
  }

  Future<void> logout() async {
    await _runAuthAction(() async {
      await _repository.signOut();
    });
  }

  void bootstrap() {
    _routeForSession(_repository.currentSession);
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      await action();
    } on AuthException catch (error) {
      Get.snackbar('Auth error', error.message);
    } catch (error) {
      Get.snackbar('Error', error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _routeForSession(Session? current) {
    final target = current == null ? AppRoutes.login : AppRoutes.dialer;
    if (Get.currentRoute == target) {
      return;
    }
    Future.microtask(() => Get.offAllNamed(target));
  }
}
