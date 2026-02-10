import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../app/routes/app_routes.dart';
import '../../../core/config/supabase_service.dart';
import '../../../core/config/twilio_voice_service.dart';
import '../../history/repo/history_repository.dart';

enum CallStatus { idle, calling, connected, ended, error }

class CallController extends GetxController {
  CallController(this._voiceService, this._supabaseService, this._historyRepository);

  final TwilioVoiceService _voiceService;
  final SupabaseService _supabaseService;
  final HistoryRepository _historyRepository;

  final phoneNumber = ''.obs;
  final status = CallStatus.idle.obs;
  final errorMessage = RxnString();
  final isMuted = false.obs;
  final isSpeakerOn = false.obs;
  final elapsedSeconds = 0.obs;

  StreamSubscription<CallStateEvent>? _stateSubscription;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is String && args.trim().isNotEmpty) {
      phoneNumber.value = args.trim();
    }
    _voiceService.init();
    _stateSubscription = _voiceService.events.listen(_handleCallState);
  }

  @override
  void onReady() {
    super.onReady();
    if (phoneNumber.value.isNotEmpty) {
      startOutgoingCall();
    } else {
      _setError('Missing destination number.');
    }
  }

  @override
  void onClose() {
    _stateSubscription?.cancel();
    _stopTimer();
    super.onClose();
  }

  Future<void> startOutgoingCall() async {
    if (status.value == CallStatus.calling || status.value == CallStatus.connected) {
      return;
    }

    final identity = _supabaseService.client.auth.currentUser?.id;
    if (identity == null || identity.isEmpty) {
      _setError('Missing user session. Please login again.');
      return;
    }

    status.value = CallStatus.calling;
    errorMessage.value = null;

    try {
      final token = await _fetchToken(identity);
      await _voiceService.startCall(accessToken: token, to: phoneNumber.value);
    } catch (error) {
      _setError(error.toString());
    }
  }

  Future<void> endCall() async {
    await _voiceService.endCall();
    _finalizeCall(CallStatus.ended, message: null);
  }

  Future<void> toggleMute() async {
    final next = !isMuted.value;
    isMuted.value = next;
    await _voiceService.setMute(next);
  }

  Future<void> toggleSpeaker() async {
    final next = !isSpeakerOn.value;
    isSpeakerOn.value = next;
    await _voiceService.setSpeaker(next);
  }

  String formattedDuration() {
    final total = elapsedSeconds.value;
    final minutes = total ~/ 60;
    final seconds = total % 60;
    final minuteStr = minutes.toString().padLeft(2, '0');
    final secondStr = seconds.toString().padLeft(2, '0');
    return '$minuteStr:$secondStr';
  }

  void _handleCallState(CallStateEvent event) {
    switch (event.state) {
      case 'calling':
        status.value = CallStatus.calling;
        break;
      case 'connected':
        status.value = CallStatus.connected;
        _startTimer();
        break;
      case 'ended':
        _finalizeCall(CallStatus.ended, message: event.message);
        break;
      case 'error':
        _finalizeCall(CallStatus.error, message: event.message);
        break;
      default:
        break;
    }
  }

  Future<String> _fetchToken(String identity) async {
    final uri = Uri.parse('${SupabaseService.functionsBaseUrl}/token').replace(
      queryParameters: {'identity': identity},
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Token request failed (${response.statusCode}).');
    }

    final body = response.body.trim();
    if (body.isEmpty) {
      throw Exception('Token response was empty.');
    }

    try {
      final data = jsonDecode(body);
      if (data is Map && data['token'] is String) {
        return data['token'] as String;
      }
      if (data is Map && data['access_token'] is String) {
        return data['access_token'] as String;
      }
    } catch (_) {
      // Ignore JSON errors and treat response as raw token.
    }

    return body;
  }

  void _setError(String message) {
    status.value = CallStatus.error;
    errorMessage.value = message;
    Get.snackbar('Call error', message);
  }

  void _finalizeCall(CallStatus newStatus, {String? message}) {
    status.value = newStatus;
    if (message != null && message.isNotEmpty) {
      errorMessage.value = message;
      if (newStatus == CallStatus.error) {
        Get.snackbar('Call error', message);
      }
    }
    _stopTimer();
    isMuted.value = false;
    isSpeakerOn.value = false;

    if (phoneNumber.value.isNotEmpty) {
      _historyRepository.add(phoneNumber.value);
    }

    if (Get.currentRoute != AppRoutes.history) {
      Get.offAllNamed(AppRoutes.history);
    }
  }

  void _startTimer() {
    _stopTimer();
    elapsedSeconds.value = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds.value += 1;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
