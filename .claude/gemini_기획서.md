[PRD] Voicelog AI (음성 기반 스마트 일기장) 개발 기획서

1. 프로젝트 개요
목적: 외부 서버 통신 없이 스마트폰 내부에서 [음성 인식 -> AI 보정 -> 분석]을 완결하여 개인정보를 보호하고 응답 속도를 극대화함.

핵심 기술 (On-Device Focus):

Frontend: Flutter

STT: Android Native STT (S23 FE 내장 엔진)

On-Device LLM Inference: Google MediaPipe LLM Inference API (Flutter용)

Target Model: Gemma 2 2B (INT4 양자화 모델) - S23 FE 환경에 최적화

2. Phase 1: On-Device MVP 구현 (Local-Only)
목표: 인터넷 연결 없이 스마트폰 기기 내에서 일기 보정 및 메타데이터 추출 기능을 구현한다.

2.1. 프론트엔드 (Flutter) 요구사항
LLM 엔진 통합: * mediapipe_genai 패키지(또는 2026년 기준 최신 구글 공식 LLM 플러그인)를 사용하여 모델 파일(.bin 또는 .tflite)을 앱 에셋에 포함하거나 첫 실행 시 다운로드.

GPU/NPU 가속 설정(Delegate)을 통해 S23 FE의 성능 활용.

UI 흐름:

Recording: 마이크 버튼 클릭 시 음성 인식 시작.

On-Device Processing: 음성 인식이 끝나자마자 로컬 LLM에 텍스트 전달.

Real-time Streaming: AI가 문장을 다듬는 과정을 실시간으로 화면에 출력(Streaming).

주요 패키지:

speech_to_text: 네이티브 STT 연동.

mediapipe_genai_flutter: 온디바이스 LLM 추론.

2.2. 로컬 프롬프트 엔지니어링 (System Prompt)
로컬 모델은 파라미터가 작으므로 명확하고 간결한 인스트럭션이 중요함.

Prompt: ```text
<start_of_turn>user
당신은 일기 정리 비서입니다. 아래 텍스트를 자연스러운 독백체로 수정하고, 감정(기쁨/슬픔/평온/화남)과 키워드 3개를 추출하세요.
응답 형식:
[보정본] 내용...
[감정] 감정값
[태그] #키워드1, #키워드2, #키워드3

입력: {raw_text}<end_of_turn>
<start_of_turn>model


3. Claude Code 작업 지시 가이드 (수정본)
Claude Code에게는 이제 백엔드(FastAPI)가 아닌, Flutter 내부에 LLM 엔진을 심는 작업을 시켜야 합니다.

[작업 지시 1: 프로젝트 초기화 및 STT 설정]

"Flutter 프로젝트 voicelog_ai를 생성하고, speech_to_text 패키지를 설정해 줘. S23 FE의 네이티브 STT 엔진을 사용해서 사용자의 음성을 실시간으로 텍스트로 변환하여 화면에 보여주는 마이크 위젯 화면을 구성해 줘."

[작업 지시 2: MediaPipe LLM 엔진 통합]

"이 앱에 Google MediaPipe LLM Inference API를 통합해 줘. 기기 로컬에 저장된 gemma-2b-it-cpu-int4.bin 모델 파일을 불러와서 추론할 수 있는 서비스 클래스를 작성해 줘. STT로 변환된 텍스트를 이 모델에 입력값으로 넣어주는 파이프라인을 만들어야 해."

[작업 지시 3: 로컬 처리 로직 구현]

"사용자의 음성 인식이 완료되면, 로컬 LLM에게 '일기 보정 및 감정 추출'을 요청하는 프롬프트를 구성해 줘. 모델의 응답 스트림을 받아서 화면 하단에 실시간으로 업데이트하고, [감정]과 [태그] 부분을 파싱해서 예쁜 칩(Chip) 형태의 UI로 렌더링해 줘."

💡 시니어 개발자의 팁 (S23 FE 최적화)
모델 양자화(Quantization): S23 FE에서 8bit 모델은 무거울 수 있습니다. 반드시 **4bit 양자화(INT4)**된 모델을 사용해야 메모리 부족(OOM) 없이 부드럽게 돌아갑니다.

초기 로딩 시간: 온디바이스 LLM은 모델을 램에 올릴 때 시간이 수 초 걸립니다. 앱 실행 시 미리 Warm-up 하거나, 로딩 애니메이션을 세련되게 넣어 UX를 보완하세요.

발열 관리: LLM 추론은 배터리 소모와 발열이 큽니다. 일기 작성이 완료된 후에는 모델 세션을 즉시 닫거나 절전 모드로 전환하는 로직이 필요합니다.