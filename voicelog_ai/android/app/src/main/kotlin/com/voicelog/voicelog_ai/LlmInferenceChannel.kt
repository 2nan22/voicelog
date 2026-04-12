package com.voicelog.voicelog_ai

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.google.mediapipe.tasks.genai.llminference.LlmInference
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Flutter ↔ Android MediaPipe LLM 브리지.
 *
 * MethodChannel  "voicelog/llm"        : initialize(modelPath), dispose
 * EventChannel   "voicelog/llm_stream" : generateStream(prompt) → token 스트림
 *
 * mediapipe_genai Flutter 패키지(Native Assets 의존)를 대체한다.
 * Android MediaPipe Tasks GenAI AAR(tasks-genai)을 직접 사용한다.
 */
class LlmInferenceChannel(private val context: Context) : MethodChannel.MethodCallHandler {

    private var llmInference: LlmInference? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    // EventChannel.StreamHandler — 생성 스트림 관리
    val streamHandler = object : EventChannel.StreamHandler {

        // onListen: Dart 측 subscribe 시 호출. arguments = {'prompt': '...'}
        override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
            val args = arguments as? Map<*, *>
            val prompt = args?.get("prompt") as? String
            if (prompt == null) {
                events.error("INVALID_ARGS", "prompt 파라미터가 없습니다.", null)
                return
            }

            val inference = llmInference
            if (inference == null) {
                events.error("NOT_INITIALIZED", "LLM이 초기화되지 않았습니다.", null)
                return
            }

            try {
                inference.generateResponseAsync(prompt) { partialResult: String?, done: Boolean ->
                    mainHandler.post {
                        if (done) {
                            events.endOfStream()
                        } else if (!partialResult.isNullOrEmpty()) {
                            events.success(partialResult)
                        }
                    }
                }
            } catch (e: Exception) {
                mainHandler.post {
                    events.error("GENERATE_ERROR", e.message ?: "추론 오류", null)
                }
            }
        }

        override fun onCancel(arguments: Any?) {
            // LlmInference는 취소 API가 없으므로 sink만 해제
        }
    }

    // MethodChannel.MethodCallHandler
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> handleInitialize(call, result)
            "dispose"    -> handleDispose(result)
            else         -> result.notImplemented()
        }
    }

    private fun handleInitialize(call: MethodCall, result: MethodChannel.Result) {
        val modelPath = call.argument<String>("modelPath")
        if (modelPath.isNullOrEmpty()) {
            result.error("INVALID_ARGS", "modelPath 파라미터가 없습니다.", null)
            return
        }

        try {
            // 기존 인스턴스 정리
            llmInference?.close()

            val options = LlmInference.Options.builder()
                .setModelPath(modelPath)
                .setMaxTokens(1024)
                .setTopK(40)
                .setTemperature(0.8f)
                .build()

            llmInference = LlmInference.createFromOptions(context, options)
            result.success(null)
        } catch (e: Exception) {
            result.error("INIT_ERROR", e.message ?: "초기화 오류", null)
        }
    }

    private fun handleDispose(result: MethodChannel.Result) {
        try {
            llmInference?.close()
            llmInference = null
            result.success(null)
        } catch (e: Exception) {
            result.error("DISPOSE_ERROR", e.message, null)
        }
    }
}
