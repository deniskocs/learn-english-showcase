package net.chilik.learn_english

import android.content.Context
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.MediaMuxer
import android.media.MediaRecorder
import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import io.flutter.plugin.common.EventChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.nio.ByteBuffer
import java.util.UUID

class ContinuousAudioRecorder(
    private val context: Context,
    private val audioChannels: AudioChannels
) {
    private var audioRecord: AudioRecord? = null
    private var isRecording = false
    private var chunkDurationSeconds: Long = 600 // 10 минут по умолчанию
    private var chunkTimer: Handler? = null
    private var timerThread: HandlerThread? = null
    private var currentChunk: ByteArrayOutputStream? = null
    
    private val sampleRate = 44100
    private val channelConfig = AudioFormat.CHANNEL_IN_MONO
    private val audioFormat = AudioFormat.ENCODING_PCM_16BIT
    private val bitRate = 64000 // 64 kbps
    private val encoderBufferSize = 128 * 1024 // 128 KB для эффективной обработки больших чанков
    private val bufferSize: Int
    
    init {
        bufferSize = AudioRecord.getMinBufferSize(sampleRate, channelConfig, audioFormat)
    }
    
    fun startRecording(chunkDurationSeconds: Int) {
        if (isRecording) {
            Log.w(TAG, "Recording already in progress")
            return
        }
        
        this.chunkDurationSeconds = chunkDurationSeconds.toLong()
        
        try {
            // Создаем AudioRecord
            audioRecord = AudioRecord(
                MediaRecorder.AudioSource.MIC,
                sampleRate,
                channelConfig,
                audioFormat,
                bufferSize * 2
            )
            
            if (audioRecord?.state != AudioRecord.STATE_INITIALIZED) {
                throw IllegalStateException("AudioRecord initialization failed")
            }
            
            // Начинаем новый чанк
            currentChunk = ByteArrayOutputStream()
            
            // Запускаем запись
            audioRecord?.startRecording()
            isRecording = true
            
            // Запускаем поток для чтения аудио данных
            startAudioReadingThread()
            
            // Запускаем таймер для отправки чанков
            startChunkTimer()
            
            Log.d(TAG, "Continuous recording started")
        } catch (e: Exception) {
            Log.e(TAG, "Error starting recording", e)
            audioChannels.sendError("RECORDING_ERROR", e.message, null)
        }
    }
    
    private fun startAudioReadingThread() {
        val thread = Thread {
            val buffer = ByteArray(bufferSize)
            
            while (isRecording) {
                val readBytes = audioRecord?.read(buffer, 0, buffer.size) ?: 0
                
                when {
                    readBytes > 0 -> {
                        synchronized(this) {
                            currentChunk?.write(buffer, 0, readBytes)
                        }
                    }
                    readBytes == AudioRecord.ERROR_INVALID_OPERATION -> {
                        Log.e(TAG, "AudioRecord read error: ERROR_INVALID_OPERATION")
                        break
                    }
                    readBytes == AudioRecord.ERROR_BAD_VALUE -> {
                        Log.e(TAG, "AudioRecord read error: ERROR_BAD_VALUE")
                        break
                    }
                    readBytes == 0 -> {
                        // Нет данных, продолжаем чтение
                        Thread.sleep(10)
                    }
                }
            }
        }
        
        thread.start()
    }
    
    private fun startChunkTimer() {
        timerThread = HandlerThread("ChunkTimerThread").apply {
            start()
        }
        chunkTimer = Handler(timerThread?.looper!!)
        
        scheduleNextChunk()
    }
    
    private fun scheduleNextChunk() {
        if (!isRecording) return
        
        chunkTimer?.postDelayed({
            if (isRecording) {
                saveChunkAndStartNew()
                // Планируем следующий чанк
                scheduleNextChunk()
            }
        }, chunkDurationSeconds * 1000)
    }
    
    private fun saveChunkAndStartNew() {
        if (!isRecording) return
        
        synchronized(this) {
            val chunk = currentChunk?.toByteArray()
            currentChunk?.reset() // Очищаем для следующего чанка
            
            if (chunk != null && chunk.isNotEmpty()) {
                Thread {
                    sendChunk(chunk)
                }.start()
            }
        }
    }
    
    private fun createAACEncoder(): MediaCodec {
        val mimeType = MediaFormat.MIMETYPE_AUDIO_AAC
        val encoder = MediaCodec.createEncoderByType(mimeType)
        
        val format = MediaFormat.createAudioFormat(
            mimeType,
            sampleRate,
            1 // mono
        ).apply {
            setInteger(MediaFormat.KEY_AAC_PROFILE, MediaCodecInfo.CodecProfileLevel.AACObjectLC)
            setInteger(MediaFormat.KEY_BIT_RATE, bitRate)
            setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, encoderBufferSize)
        }
        
        encoder.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
        encoder.start()
        
        return encoder
    }
    
    private fun sendChunk(chunk: ByteArray) {
        try {
            val m4aData = convertPCMToM4A(chunk)
            audioChannels.sendChunk(m4aData)
        } catch (e: Exception) {
            Log.e(TAG, "Error sending chunk", e)
            audioChannels.sendError("CHUNK_ERROR", e.message, null)
        }
    }
    
    private fun convertPCMToM4A(chunk: ByteArray): ByteArray? {
        // Создаем временный файл для записи M4A
        val tempDir = File(context.cacheDir, "audio_temp")
        if (!tempDir.exists()) {
            tempDir.mkdirs()
        }
        val tempFile = File(tempDir, "${UUID.randomUUID()}.m4a")
        
        try {
            val encoder = createAACEncoder()
            
            // Создаем MediaMuxer для записи M4A файла
            val muxer = MediaMuxer(tempFile.absolutePath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
            var muxerStarted = false
            var audioTrackIndex = -1
            
            var inputOffset = 0
            var hasMoreInput = true
            var hasMoreOutput = true
            val bufferInfo = MediaCodec.BufferInfo()
            
            while (hasMoreOutput) {
                // Записываем входные данные
                if (hasMoreInput) {
                    val inputBufferIndex = encoder.dequeueInputBuffer(10000)
                    if (inputBufferIndex >= 0) {
                        val inputBuffer = encoder.getInputBuffer(inputBufferIndex)
                        inputBuffer?.clear()
                        
                        if (inputOffset < chunk.size && inputBuffer != null) {
                            val bytesToCopy = minOf(chunk.size - inputOffset, inputBuffer.remaining())
                            inputBuffer.put(chunk, inputOffset, bytesToCopy)
                            inputOffset += bytesToCopy
                            
                            encoder.queueInputBuffer(
                                inputBufferIndex,
                                0,
                                bytesToCopy,
                                System.nanoTime() / 1000,
                                if (inputOffset >= chunk.size) MediaCodec.BUFFER_FLAG_END_OF_STREAM else 0
                            )
                            
                            if (inputOffset >= chunk.size) {
                                hasMoreInput = false
                            }
                        } else {
                            encoder.queueInputBuffer(
                                inputBufferIndex,
                                0,
                                0,
                                System.nanoTime() / 1000,
                                MediaCodec.BUFFER_FLAG_END_OF_STREAM
                            )
                            hasMoreInput = false
                        }
                    }
                }
                
                // Читаем выходные данные
                val outputBufferIndex = encoder.dequeueOutputBuffer(bufferInfo, 10000)
                
                when {
                    outputBufferIndex == MediaCodec.INFO_TRY_AGAIN_LATER -> {
                        // Нет выходных данных, продолжаем
                    }
                    outputBufferIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                        val newFormat = encoder.outputFormat
                        audioTrackIndex = muxer.addTrack(newFormat)
                        muxer.start()
                        muxerStarted = true
                    }
                    outputBufferIndex >= 0 -> {
                        val outputBuffer = encoder.getOutputBuffer(outputBufferIndex)
                        if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG != 0) {
                            // Конфигурационные данные, пропускаем
                            encoder.releaseOutputBuffer(outputBufferIndex, false)
                        } else {
                            if (muxerStarted && bufferInfo.size > 0 && outputBuffer != null) {
                                outputBuffer.position(bufferInfo.offset)
                                outputBuffer.limit(bufferInfo.offset + bufferInfo.size)
                                muxer.writeSampleData(audioTrackIndex, outputBuffer, bufferInfo)
                            }
                            encoder.releaseOutputBuffer(outputBufferIndex, false)
                            
                            if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                                hasMoreOutput = false
                            }
                        }
                    }
                }
            }
            
            // Завершаем работу
            encoder.stop()
            encoder.release()
            muxer.stop()
            muxer.release()
            
            // Читаем файл в массив байтов
            val m4aData = tempFile.readBytes()
            
            // Удаляем временный файл
            tempFile.delete()
            
            return m4aData
        } catch (e: Exception) {
            Log.e(TAG, "Error converting PCM to M4A", e)
            tempFile.delete()
            return null
        }
    }
    
    fun stopRecording() {
        if (!isRecording) return
        
        isRecording = false
        
        // Останавливаем таймер
        chunkTimer?.removeCallbacksAndMessages(null)
        timerThread?.quitSafely()
        timerThread = null
        chunkTimer = null
        
        // Останавливаем запись
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
        
        // Отправляем последний чанк
        synchronized(this) {
            val chunk = currentChunk?.toByteArray()
            if (chunk != null && chunk.isNotEmpty()) {
                Thread {
                    sendChunk(chunk)
                }.start()
            }
            currentChunk = null
        }
        
        audioChannels.stopRecording()
        
        Log.d(TAG, "Recording stopped")
    }
    
    
    companion object {
        private const val TAG = "ContinuousAudioRecorder"
    }
}

