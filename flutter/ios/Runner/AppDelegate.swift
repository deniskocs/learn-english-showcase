import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var audioRecorder: ContinuousAudioRecorder?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        // Настройка MethodChannel и EventChannel для непрерывной записи
        let controller = window?.rootViewController as! FlutterViewController
        let audioChannel = FlutterMethodChannel(
            name: "com.chilik.learn_english/continuous_audio_recorder",
            binaryMessenger: controller.binaryMessenger
        )
        
        let eventChannel = FlutterEventChannel(
            name: "com.chilik.learn_english/continuous_audio_recorder_events",
            binaryMessenger: controller.binaryMessenger
        )
        
        audioRecorder = ContinuousAudioRecorder(eventChannel: eventChannel)
        
        audioChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self, let recorder = self.audioRecorder else {
                result(FlutterMethodNotImplemented)
                return
            }
            
            switch call.method {
            case "startService":
                // Фейковая задержка на 10 секунд
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                    result(nil)
                }
                
            case "startRecording":
                if let args = call.arguments as? [String: Any],
                   let chunkDuration = args["chunkDuration"] as? Int {
                    recorder.startRecording(chunkDurationSeconds: chunkDuration)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
                }
                
            case "stopRecording":
                recorder.stopRecording()
                result(nil)
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
