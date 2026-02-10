package com.example.callpilot

import android.content.Context
import android.media.AudioManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.twilio.voice.Call
import com.twilio.voice.CallException
import com.twilio.voice.ConnectOptions
import com.twilio.voice.Voice

class MainActivity : FlutterActivity() {
    private val channelName = "callpilot/twilio_voice"
    private var methodChannel: MethodChannel? = null
    private var activeCall: Call? = null
    private var audioManager: AudioManager? = null
    private var previousAudioMode: Int = AudioManager.MODE_NORMAL
    private var previousMute: Boolean = false
    private var previousSpeaker: Boolean = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startCall" -> {
                    val token = call.argument<String>("accessToken") ?: ""
                    val to = call.argument<String>("to") ?: ""
                    startCall(token, to, result)
                }
                "endCall" -> {
                    endCall()
                    result.success(null)
                }
                "setMute" -> {
                    val mute = call.argument<Boolean>("mute") ?: false
                    activeCall?.mute(mute)
                    result.success(null)
                }
                "setSpeaker" -> {
                    val speaker = call.argument<Boolean>("speaker") ?: false
                    setSpeakerphoneOn(speaker)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startCall(accessToken: String, to: String, result: MethodChannel.Result) {
        if (accessToken.isBlank()) {
            result.error("missing_token", "Access token is missing", null)
            return
        }
        if (to.isBlank()) {
            result.error("missing_to", "Destination number is missing", null)
            return
        }

        activeCall?.disconnect()

        val params = HashMap<String, String>()
        params["To"] = to

        val connectOptions = ConnectOptions.Builder(accessToken)
            .params(params)
            .build()

        activeCall = Voice.connect(this, connectOptions, callListener)
        emitState("calling", null)
        result.success(null)
    }

    private fun endCall() {
        val call = activeCall
        if (call != null) {
            call.disconnect()
        } else {
            emitState("ended", null)
        }
        activeCall = null
    }

    private fun setSpeakerphoneOn(enabled: Boolean) {
        val manager = audioManager ?: return
        manager.isSpeakerphoneOn = enabled
    }

    private fun configureAudio(enable: Boolean) {
        val manager = audioManager ?: return
        if (enable) {
            previousAudioMode = manager.mode
            previousMute = manager.isMicrophoneMute
            previousSpeaker = manager.isSpeakerphoneOn
            manager.mode = AudioManager.MODE_IN_COMMUNICATION
            manager.isMicrophoneMute = false
            manager.isSpeakerphoneOn = false
        } else {
            manager.mode = previousAudioMode
            manager.isMicrophoneMute = previousMute
            manager.isSpeakerphoneOn = previousSpeaker
        }
    }

    private val callListener = object : Call.Listener {
        override fun onRinging(call: Call) {
            emitState("calling", null)
        }

        override fun onConnected(call: Call) {
            activeCall = call
            configureAudio(true)
            emitState("connected", null)
        }

        override fun onReconnecting(call: Call, error: CallException) {
            emitState("calling", error.message)
        }

        override fun onReconnected(call: Call) {
            emitState("connected", null)
        }

        override fun onConnectFailure(call: Call, error: CallException) {
            activeCall = null
            configureAudio(false)
            emitState("error", error.message)
        }

        override fun onDisconnected(call: Call, error: CallException?) {
            activeCall = null
            configureAudio(false)
            if (error != null) {
                emitState("error", error.message)
            } else {
                emitState("ended", null)
            }
        }
    }

    private fun emitState(state: String, message: String?) {
        val args: HashMap<String, Any?> = HashMap()
        args["state"] = state
        if (message != null) {
            args["message"] = message
        }
        runOnUiThread {
            methodChannel?.invokeMethod("callState", args)
        }
    }
}
