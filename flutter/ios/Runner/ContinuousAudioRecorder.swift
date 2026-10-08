import Foundation
import AVFoundation
import AudioToolbox
import Flutter

class AudioChunk {
    let startTime: Date
    var data: Data
    
    init(startTime: Date = Date()) {
        self.startTime = startTime
        self.data = Data()
    }
    
    var size: Int {
        return data.count
    }
    
    var timestamp: TimeInterval {
        return startTime.timeIntervalSince1970
    }
}

class ContinuousAudioRecorder: NSObject {
    private var audioEngine: AVAudioEngine?
    private var isRecording = false
    private var chunkDuration: TimeInterval = 600 // 10 минут по умолчанию
    private var chunkTimer: Timer?
    private var currentChunk: AudioChunk?
    private var eventSink: FlutterEventSink?
    
    init(eventChannel: FlutterEventChannel) {
        super.init()
        
        // Настраиваем EventChannel для отправки событий
        eventChannel.setStreamHandler(self)
        
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }
    
    func startRecording(chunkDurationSeconds: Int) {
        guard !isRecording else {
            print("Recording already in progress")
            return
        }
        
        self.chunkDuration = TimeInterval(chunkDurationSeconds)
        
        do {
            // Создаем аудио движок
            audioEngine = AVAudioEngine()
            guard let engine = audioEngine else {
                throw NSError(domain: "AudioRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create audio engine"])
            }
            
            let inputNode = engine.inputNode
            let inputFormat = inputNode.inputFormat(forBus: 0)
            
            // Создаем моно формат (1 канал)
            guard let monoFormat = AVAudioFormat(commonFormat: inputFormat.commonFormat, sampleRate: inputFormat.sampleRate, channels: 1, interleaved: false) else {
                throw NSError(domain: "AudioRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create mono format"])
            }
            
            // Начинаем новый чанк
            currentChunk = AudioChunk()
            
            // Устанавливаем обработчик для записи аудио в моно формате
            inputNode.installTap(onBus: 0, bufferSize: 4096, format: monoFormat) { [weak self] (buffer, time) in
                self?.processAudioBuffer(buffer)
            }
            
            try engine.start()
            isRecording = true
            
            // Запускаем таймер для отправки чанков
            startChunkTimer()
            
            print("Continuous recording started")
        } catch {
            print("Error starting recording: \(error)")
            eventSink?([
                "event": "error",
                "error": error.localizedDescription
            ])
        }
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard isRecording,
              let channelData = buffer.floatChannelData
        else { return }
        
        let byteCount = Int(buffer.frameLength) * MemoryLayout<Float>.size
        let data = Data(
            bytes: channelData[0],
            count: byteCount
        )
        
        currentChunk?.data.append(data)
    }
    
    private func startChunkTimer() {
        chunkTimer?.invalidate()
        chunkTimer = Timer.scheduledTimer(withTimeInterval: chunkDuration, repeats: true) { [weak self] _ in
            self?.saveChunkAndStartNew()
        }
    }
    
    private func sendChunk(_ chunk: AudioChunk) {
        print("Sending chunk, PCM size: \(chunk.size) bytes")
        
        // Конвертируем PCM данные в M4A
        guard let m4aData = convertPCMToM4A(pcmData: chunk.data) else {
            print("Failed to convert PCM to M4A")
            eventSink?([
                "event": "error",
                "error": "Failed to convert PCM to M4A"
            ])
            return
        }
        
        print("M4A conversion successful, size: \(m4aData.count) bytes")
        
        // Отправляем только данные напрямую
        let typedData = FlutterStandardTypedData(bytes: m4aData)
        eventSink?(typedData)
    }
    
    private func convertPCMToM4A(pcmData: Data) -> Data? {
        // Параметры аудио: моно, 44100 Hz, Float32
        let sampleRate: Double = 44100
        let channels: UInt32 = 1
        
        // Вычисляем количество фреймов
        let frameCount = pcmData.count / MemoryLayout<Float>.size
        
        // Создаем временный файл для записи M4A
        let tempDir = FileManager.default.temporaryDirectory
        let tempFileURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("m4a")
        
        // Удаляем файл, если он существует
        if FileManager.default.fileExists(atPath: tempFileURL.path) {
            try? FileManager.default.removeItem(at: tempFileURL)
        }
        
        // Создаем ASBD для входного формата (PCM Float32)
        var inputFormat = AudioStreamBasicDescription(
            mSampleRate: sampleRate,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved,
            mBytesPerPacket: UInt32(MemoryLayout<Float>.size),
            mFramesPerPacket: 1,
            mBytesPerFrame: UInt32(MemoryLayout<Float>.size),
            mChannelsPerFrame: channels,
            mBitsPerChannel: 32,
            mReserved: 0
        )
        
        // Создаем ASBD для выходного формата (AAC)
        var outputFormat = AudioStreamBasicDescription(
            mSampleRate: sampleRate,
            mFormatID: kAudioFormatMPEG4AAC,
            mFormatFlags: 0,
            mBytesPerPacket: 0,
            mFramesPerPacket: 1024,
            mBytesPerFrame: 0,
            mChannelsPerFrame: channels,
            mBitsPerChannel: 0,
            mReserved: 0
        )
        
        // Создаем ExtAudioFile для записи
        var audioFile: ExtAudioFileRef?
        var status = ExtAudioFileCreateWithURL(
            tempFileURL as CFURL,
            kAudioFileM4AType,
            &outputFormat,
            nil,
            AudioFileFlags.eraseFile.rawValue,
            &audioFile
        )
        
        guard status == noErr, let file = audioFile else {
            print("Failed to create ExtAudioFile: \(status)")
            return nil
        }
        
        // Устанавливаем формат клиента (входной формат)
        status = ExtAudioFileSetProperty(
            file,
            kExtAudioFileProperty_ClientDataFormat,
            UInt32(MemoryLayout<AudioStreamBasicDescription>.size),
            &inputFormat
        )
        
        guard status == noErr else {
            print("Failed to set client data format: \(status)")
            ExtAudioFileDispose(file)
            return nil
        }
        
        // Записываем данные
        pcmData.withUnsafeBytes { bytes in
            let floatPointer = bytes.assumingMemoryBound(to: Float.self)
            var bufferList = AudioBufferList(
                mNumberBuffers: 1,
                mBuffers: AudioBuffer(
                    mNumberChannels: channels,
                    mDataByteSize: UInt32(pcmData.count),
                    mData: UnsafeMutableRawPointer(mutating: floatPointer.baseAddress)
                )
            )
            
            var framesToWrite = UInt32(frameCount)
            status = ExtAudioFileWrite(file, framesToWrite, &bufferList)
            
            if status != noErr {
                print("Failed to write audio data: \(status)")
            }
        }
        
        // Закрываем файл
        status = ExtAudioFileDispose(file)
        
        guard status == noErr else {
            print("Failed to close audio file: \(status)")
            return nil
        }
        
        // Проверяем, что файл существует и имеет размер
        guard FileManager.default.fileExists(atPath: tempFileURL.path) else {
            print("M4A file was not created")
            return nil
        }
        
        let fileAttributes = try? FileManager.default.attributesOfItem(atPath: tempFileURL.path)
        let fileSize = fileAttributes?[.size] as? Int ?? 0
        
        if fileSize == 0 {
            print("M4A file is empty")
            return nil
        }
        
        print("M4A file created, size: \(fileSize) bytes")
        
        // Читаем бинарные данные из файла
        guard let m4aData = try? Data(contentsOf: tempFileURL) else {
            print("Failed to read M4A file")
            return nil
        }
        
        // Удаляем временный файл
        try? FileManager.default.removeItem(at: tempFileURL)
        
        return m4aData
    }
    
    private func startNewChunk() {
        currentChunk = AudioChunk()
    }
    
    private func saveChunkAndStartNew() {
        guard isRecording else { return }
        
        // Отправляем текущий чанк с данными
        if let chunk = currentChunk {
            sendChunk(chunk)
        }
        
        // Начинаем новый чанк (запись продолжается без остановки)
        startNewChunk()
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        isRecording = false
        chunkTimer?.invalidate()
        chunkTimer = nil
        
        // Останавливаем движок
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        
        // Отправляем последний чанк с данными
        if let chunk = currentChunk {
            sendChunk(chunk)
        }
        
        // Отправляем событие об остановке записи
        eventSink?([
            "event": "recordingStopped"
        ])
        
        audioEngine = nil
        currentChunk = nil
        
        print("Recording stopped")
    }
    
    deinit {
        stopRecording()
    }
}

// MARK: - FlutterStreamHandler
extension ContinuousAudioRecorder: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

