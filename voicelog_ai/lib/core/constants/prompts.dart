// ── 모델 파일 설정 ────────────────────────────────────────────────────────────
/// Gemma 2B IT INT4 — MediaPipe CPU 추론용 모델
/// 파일 크기: 약 1.35 GB
/// 수동 다운로드: HuggingFace 로그인 + Gemma 라이선스 동의 후 다운로드
/// https://huggingface.co/google/gemma-2b-it-tflite
const String kModelHuggingFacePage = 'https://huggingface.co/google/gemma-2b-it-tflite';
const String kModelFileName = 'gemma-2b-it-cpu-int4.bin';
const String kModelSubDir = 'models';

/// 일기 보정 및 감정/태그 추출 프롬프트.
/// {raw_text} 자리에 STT 원문을 치환하여 사용한다.
const String kDiaryProcessingPrompt = '''
<start_of_turn>user
당신은 일기 정리 비서입니다. 아래 텍스트를 자연스러운 독백체로 수정하고,
감정(기쁨/슬픔/평온/화남)과 키워드 3개를 추출하세요.
응답 형식:
[보정본] 내용...
[감정] 감정값
[태그] #키워드1, #키워드2, #키워드3

입력: {raw_text}<end_of_turn>
<start_of_turn>model
''';
