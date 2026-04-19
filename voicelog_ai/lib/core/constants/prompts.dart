import 'package:voicelog_ai/features/settings/domain/app_settings.dart';

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

// ── 문체별 프롬프트 지시문 ────────────────────────────────────────────────────
/// 문체별 보정 지시문. kCorrectionPrompt의 {style_instruction} 자리에 치환.
const Map<WritingStyle, String> kWritingStyleInstructions = {
  WritingStyle.diary:  '자연스러운 1인칭 독백 일기체로',
  WritingStyle.memo:   '핵심만 간결하게 메모체로',
  WritingStyle.letter: '따뜻하고 감성적인 편지체로',
};

/// 메타데이터 추출 프롬프트 — 항상 실행. 보정 없이 구조화 정보만 추출.
/// {raw_text} 자리에 STT 원문을 치환한다.
const String kMetadataExtractionPrompt = '''
<|im_start|>user
아래 음성 일기 텍스트에서 정보를 추출하세요.
응답은 반드시 아래 형식만 사용하고 설명을 추가하지 마세요.

[제목] 한 줄 제목 (20자 이내)
[감정] 기쁨 또는 슬픔 또는 평온 또는 화남 중 하나
[태그] #키워드1, #키워드2, #키워드3
[인물] 이름1, 이름2 (없으면 없음)
[장소] 장소1, 장소2 (없으면 없음)

텍스트: {raw_text}<|im_end|>
<|im_start|>assistant
''';

/// 문맥 보정 프롬프트 — 설정에서 활성화 시에만 실행.
/// {style_instruction} 과 {raw_text} 를 치환한다.
const String kCorrectionPrompt = '''
<|im_start|>user
아래 음성 일기 텍스트를 {style_instruction} 수정하세요.
오탈자와 어색한 표현만 최소한으로 수정하고 내용은 바꾸지 마세요.
[보정본] 태그로 시작해서 보정된 텍스트만 출력하세요.

[보정본] 보정된 내용...

텍스트: {raw_text}<|im_end|>
<|im_start|>assistant
''';
