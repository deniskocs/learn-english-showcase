package net.chilik.learn_english

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel.Result

class MainActivity : FlutterActivity() {
    private var audioRecordingService: AudioRecordingService? = null
    private var pendingStartServiceResult: Result? = null
    private lateinit var audioChannels: AudioChannels
    
    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            val binder = service as AudioRecordingService.LocalBinder
            audioRecordingService = binder.getService()

            audioRecordingService?.initRecorder(audioChannels)

            pendingStartServiceResult?.success(null)
            pendingStartServiceResult = null
        }
        
        override fun onServiceDisconnected(name: ComponentName?) {
            audioRecordingService = null
        }
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        audioChannels = AudioChannels(flutterEngine)
        
        audioChannels.onStartService = { result ->
            if (audioRecordingService != null) {
                result.success(null)
            } else {
                pendingStartServiceResult = result
                val serviceIntent = Intent(this, AudioRecordingService::class.java)
                startForegroundService(serviceIntent)
                bindService(serviceIntent, serviceConnection, Context.BIND_AUTO_CREATE)
            }
        }
        
        audioChannels.onStartRecording = { chunkDuration, result ->
            if (audioRecordingService == null) {
                result.error("SERVICE_NOT_READY", "Service is not ready", null)
            } else {
                try {
                    audioRecordingService?.startRecording(chunkDuration)
                    result.success(null)
                } catch (e: SecurityException) {
                    result.error("PERMISSION_DENIED", "RECORD_AUDIO permission not granted: ${e.message}", null)
                } catch (e: Exception) {
                    result.error("SERVICE_ERROR", "Failed to start foreground recording: ${e.message}", null)
                }
            }
        }
        
        audioChannels.onStopRecording = { result ->
            audioRecordingService?.stopForegroundRecording()
            result.success(null)
        }
        
        audioChannels.setMethodCallHandler()
    }
    
    override fun onDestroy() {
        super.onDestroy()
        if (audioRecordingService != null) {
            unbindService(serviceConnection)
            audioRecordingService = null
        }
    }
}
