// ── LLM 추론 설정 ─────────────────────────────────────────────────────────────
/// CPU 백엔드(LiteRT)에서 Qwen2.5 1.5B 추론은 수 분 소요될 수 있다.
/// 경고 다이얼로그는 추론이 이 시간을 초과할 때만 표시한다.
const int kInferenceTimeoutSeconds = 180;

// ── 모델 파일 설정 ────────────────────────────────────────────────────────────
/// Qwen2.5 1.5B Instruct INT8 — MediaPipe .task 형식, 인증 없이 다운로드 가능
/// 출처: https://huggingface.co/litert-community/Qwen2.5-1.5B-Instruct
/// 파일 크기: 약 1.6 GB
const String kModelDownloadUrl =
    'https://huggingface.co/litert-community/Qwen2.5-1.5B-Instruct/resolve/main/'
    'Qwen2.5-1.5B-Instruct_multi-prefill-seq_q8_ekv1280.task';
const String kModelFileName = 'Qwen2.5-1.5B-Instruct_q8.task';
const String kModelSubDir = 'models';

/// 일기 보정 및 감정/태그 추출 프롬프트 (Qwen2.5 채팅 포맷).
/// {raw_text} 자리에 STT 원문을 치환하여 사용한다.
const String kDiaryProcessingPrompt = '''
<|im_start|>user
당신은 일기 정리 비서입니다. 아래 텍스트를 자연스러운 독백체로 수정하고,
감정(기쁨/슬픔/평온/화남)과 키워드 3개를 추출하세요.
응답 형식:
[보정본] 내용...
[감정] 감정값
[태그] #키워드1, #키워드2, #키워드3

입력: {raw_text}<|im_end|>
<|im_start|>assistant
''';
