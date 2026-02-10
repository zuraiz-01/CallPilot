import 'dart:async';

import 'package:flutter/services.dart';

class CallStateEvent {
  const CallStateEvent({required this.state, this.message});

  final String state;
  final String? message;
}

class TwilioVoiceService {
  static const MethodChannel _channel = MethodChannel('callpilot/twilio_voice');

  final StreamController<CallStateEvent> _controller =
      StreamController<CallStateEvent>.broadcast();
  bool _initialized = false;

  Stream<CallStateEvent> get events => _controller.stream;

  Future<void> init() async {
    if (_initialized) {
      return;
    }
    _channel.setMethodCallHandler(_handleMethodCall);
    _initialized = true;
  }

  Future<void> startCall({required String accessToken, required String to}) {
    return _channel.invokeMethod('startCall', {
      'accessToken': accessToken,
      'to': to,
    });
  }

  Future<void> endCall() {
    return _channel.invokeMethod('endCall');
  }

  Future<void> setMute(bool mute) {
    return _channel.invokeMethod('setMute', {'mute': mute});
  }

  Future<void> setSpeaker(bool speaker) {
    return _channel.invokeMethod('setSpeaker', {'speaker': speaker});
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method != 'callState') {
      return;
    }
    final args = call.arguments;
    if (args is Map) {
      final state = args['state']?.toString() ?? 'unknown';
      final message = args['message']?.toString();
      _controller.add(CallStateEvent(state: state, message: message));
    }
  }
}
