package com.voicelog.voicelog_ai

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    companion object {
        init {
            // mediapipe_genai native assets가 Flutter 3.41.6 stable에서
            // 자동 번들되지 않으므로 jniLibs에서 직접 로드한다.
            // Dart FFI의 process lookup fallback이 이 심볼을 찾게 된다.
            System.loadLibrary("llm_inference_engine")
        }
    }
}
