package net.chilik.learn_english

import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result

class AudioChannels(flutterEngine: FlutterEngine) : EventChannel.StreamHandler {
    val audioChannel: MethodChannel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        "com.chilik.learn_english/continuous_audio_recorder"
    )
    
    val eventChannel: EventChannel = EventChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        "com.chilik.learn_english/continuous_audio_recorder_events"
    )
    
    var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    
    var onStartService: ((Result) -> Unit)? = null
    var onStartRecording: ((Int, Result) -> Unit)? = null
    var onStopRecording: ((Result) -> Unit)? = null
    
    init {
        eventChannel.setStreamHandler(this)
    }
    
    fun setMethodCallHandler() {
        audioChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    onStartService?.invoke(result) ?: result.notImplemented()
                }
                "startRecording" -> {
                    val chunkDuration = call.argument<Int>("chunkDuration")
                    if (chunkDuration == null) {
                        result.error("INVALID_ARGUMENT", "Invalid arguments", null)
                        return@setMethodCallHandler
                    }
                    onStartRecording?.invoke(chunkDuration, result) ?: result.notImplemented()
                }
                "stopRecording" -> {
                    onStopRecording?.invoke(result) ?: result.notImplemented()
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.eventSink = events
    }
    
    override fun onCancel(arguments: Any?) {
        this.eventSink = null
    }
    
    fun sendChunk(m4aData: ByteArray?) {
        if (m4aData == null || m4aData.isEmpty()) {
            Log.e(TAG, "Failed to convert PCM to M4A")
            sendError("CONVERSION_ERROR", "Failed to convert PCM to M4A", null)
            return
        }
        
        mainHandler.post {
            eventSink?.success(m4aData)
        }
    }
    
    fun sendError(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        mainHandler.post {
            eventSink?.error(errorCode, errorMessage, errorDetails)
        }
    }
    
    fun sendSuccess(data: Any) {
        mainHandler.post {
            eventSink?.success(data)
        }
    }
    
    fun stopRecording() {
        mainHandler.post {
            eventSink?.success(mapOf("event" to "recordingStopped"))
        }
    }
    
    companion object {
        private const val TAG = "AudioChannels"
    }
}

