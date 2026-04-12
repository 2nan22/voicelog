package com.voicelog.voicelog_ai

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.google.mediapipe.tasks.genai.llminference.LlmInference
import com.google.mediapipe.tasks.genai.llminference.LlmInferenceSession
import com.google.mediapipe.tasks.genai.llminference.LlmInferenceSession.LlmInferenceSessionOptions
import com.google.mediapipe.tasks.genai.llminference.ProgressListener
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Flutter ↔ Android MediaPipe Tasks GenAI 브리지 (Native Assets 없음).
 *
 * MethodChannel "voicelog/llm"        : initialize(modelPath), dispose
 * EventChannel  "voicelog/llm_stream" : 토큰 스트리밍 (arguments = {prompt: "..."})
 */
class LlmInferenceChannel(private val context: Context) : MethodChannel.MethodCallHandler {

    private var llmInference: LlmInference? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    // ─── EventChannel.StreamHandler ───────────────────────────────────────────
    val streamHandler = object : EventChannel.StreamHandler {

        override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
            val prompt = (arguments as? Map<*, *>)?.get("prompt") as? String
            if (prompt == null) {
                events.error("INVALID_ARGS", "prompt 파라미터가 없습니다.", null)
                return
            }

            val inference = llmInference ?: run {
                events.error("NOT_INITIALIZED", "LLM이 초기화되지 않았습니다.", null)
                return
            }

            try {
                val sessionOptions = LlmInferenceSessionOptions.builder()
                    .setTemperature(0.8f)
                    .setTopK(40)
                    .setTopP(0.9f)
                    .build()

                val session = LlmInferenceSession.createFromOptions(inference, sessionOptions)
                session.addQueryChunk(prompt)
                session.generateResponseAsync(ProgressListener<String> { partial, done ->
                    mainHandler.post {
                        if (done) {
                            session.close()
                            events.endOfStream()
                        } else if (!partial.isNullOrEmpty()) {
                            events.success(partial)
                        }
                    }
                })
            } catch (e: Exception) {
                mainHandler.post {
                    events.error("GENERATE_ERROR", e.message ?: "추론 오류", null)
                }
            }
        }

        override fun onCancel(arguments: Any?) {
            // 취소 API 미지원 — sink 해제만
        }
    }

    // ─── MethodChannel.MethodCallHandler ──────────────────────────────────────
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
            result.error("INVALID_ARGS", "modelPath가 없습니다.", null)
            return
        }
        try {
            llmInference?.close()
            // Backend.CPU = 새 LiteRT CPU 경로 (Qwen2.5 input mask 지원)
            // Backend.GPU는 Exynos 2200 (S23 FE KR)에서 libvndksupport.so 미존재로 SIGSEGV 발생 — 사용 금지
            val options = LlmInference.LlmInferenceOptions.builder()
                .setModelPath(modelPath)
                .setMaxTokens(1024)
                .setPreferredBackend(LlmInference.Backend.CPU)
                .build()
            llmInference = LlmInference.createFromOptions(context, options)
            result.success(null)
        } catch (e: Exception) {
            result.error("INIT_ERROR", e.message ?: "초기화 오류", null)
        }
    }

    private fun handleDispose(result: MethodChannel.Result) {
        llmInference?.close()
        llmInference = null
        result.success(null)
    }

}
