---
name: vision-critique
description: |
  자체 품질 평가(Self-Correction) 스킬.
  A) 이미지 에셋 생성 → Gemini Vision 평가 → 재생성 루프
  B) HTML 디자인 작업 → 스크린샷 캡처 → Gemini Vision 평가 → CSS 수정 루프
  모든 디자인 작업에서 최소 1회 피드백 루프를 반드시 거칠 것.
---

# Vision Critique — 자체 품질 평가 스킬

## 핵심 원칙
**만든다 → 본다 → 판단한다 → 고친다**

## A. 이미지 에셋 피드백 루프

### 프로세스
```
1. 나노바나나로 이미지 생성
2. 생성된 이미지를 Gemini에 보내서 비평 요청
3. 비평 기반 프롬프트 수정
4. 재생성 (최대 3회, 7점 이상이면 통과)
```

### Step 1: 이미지 생성
```bash
curl -s "https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{"parts": [{"text": "PROMPT"}]}],
    "generationConfig": {"responseModalities": ["TEXT", "IMAGE"]}
  }' | python3 -c "
import sys, json, base64
data = json.load(sys.stdin)
for part in data['candidates'][0]['content']['parts']:
    if 'inlineData' in part:
        img = base64.b64decode(part['inlineData']['data'])
        with open('/tmp/generated.png', 'wb') as f: f.write(img)
        print(f'✅ Saved: {len(img)} bytes')
"
```

### Step 2: Vision 비평
```bash
IMG_B64=$(base64 -w0 /tmp/generated.png)
curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"contents\": [{
      \"parts\": [
        {\"text\": \"CRITIQUE_PROMPT_HERE\"},
        {\"inlineData\": {\"mimeType\": \"image/png\", \"data\": \"${IMG_B64}\"}}
      ]
    }]
  }"
```

### Step 3: 비평 기반 수정 → 재생성 (최대 3회)

---

## B. HTML 디자인 피드백 루프 ⭐ (핵심)

HTML 프로토타입 작업 시, **완성 후 반드시 자체 평가**를 거친다.

### 프로세스
```
1. HTML/CSS 작성 완료
2. Playwright로 스크린샷 캡처
3. 스크린샷을 Gemini Vision에 보내서 디자인 비평
4. 비평 기반 CSS 수정
5. 재캡처 + 재평가 (1-2회)
```

### Step 1: 스크린샷 캡처
```bash
# Playwright로 모바일 뷰 캡처 (430px 기준)
npx playwright screenshot \
  --viewport-size="430,932" \
  --full-page \
  "http://3.38.240.35:3000/design/v4/파일명.html" \
  /tmp/screenshot.png
```

### Step 2: Gemini Vision 디자인 비평
```bash
IMG_B64=$(base64 -w0 /tmp/screenshot.png)
curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"contents\": [{
      \"parts\": [
        {\"text\": \"$(cat <<'PROMPT'
이 모바일 앱 UI 스크린샷을 전문 UI/UX 디자이너 관점에서 평가해줘.

평가 항목:
1. 레이아웃 정렬 (1-10): 요소 간 간격 균일한가? 좌우 여백 일관적인가? 비뚤어진 요소 없는가?
2. 시각적 위계 (1-10): 중요한 정보가 눈에 먼저 들어오는가? 폰트 사이즈/굵기 차이가 적절한가?
3. 색상 조화 (1-10): 색상이 과하지 않은가? 배경과 전경의 대비가 적절한가?
4. 카드/컴포넌트 (1-10): 카드 간격이 균일한가? 카드 내부 패딩이 충분한가? 불필요한 배경색이 있는가?
5. 아이콘 (1-10): 각 섹션 아이콘이 의미에 맞는가? 이모지 사용하지 않았는가?
6. 전체 완성도 (1-10): 프로덕션 앱으로 출시해도 될 수준인가?

종합 점수: _/10
구체적 문제점 (있다면):
- 문제 1: [위치] + [문제 설명] + [수정 방안]
- 문제 2: ...
PROMPT
)\"},
        {\"inlineData\": {\"mimeType\": \"image/png\", \"data\": \"${IMG_B64}\"}}
      ]
    }]
  }" | python3 -c "
import sys, json
data = json.load(sys.stdin)
if 'error' in data:
    print('Error:', data['error'].get('message','')[:200])
else:
    print(data['candidates'][0]['content']['parts'][0]['text'])
"
```

### Step 3: 비평 기반 CSS 수정 → 재캡처 (1-2회)
- 7점 이상이면 통과
- 7점 미만 항목이 있으면 해당 부분 수정 후 재평가

---

## 비평 프롬프트 템플릿 (이미지 에셋용)

### 앱 아이콘
```
이 앱 아이콘을 평가해줘:
1. 작은 크기(32px)에서도 식별 가능한가?
2. 앱스토어 배경(흰/검)에서 잘 보이는가?
3. 경쟁 앱 아이콘과 구별되는가?
4. 브랜드 정체성이 명확한가?
점수 (1-10) + 개선사항
```

### 로고
```
이 로고를 평가해줘:
1. 텍스트가 정확하고 가독성 좋은가?
2. 축소/확대 시 품질이 유지되는가?
3. 단색 변환 시에도 식별 가능한가?
점수 (1-10) + 개선사항
```

### 마케팅 배너
```
이 마케팅 배너를 평가해줘:
1. 핵심 메시지가 3초 내에 전달되는가?
2. CTA가 명확한가?
3. 시각적 위계가 적절한가?
점수 (1-10) + 개선사항
```

## API Keys
```bash
FREE_KEY="AIzaSyB2kUIBrkW4pKYq868USGbkdZI26jv1j6s"
PAID_KEY="AIzaSyBbx45pSjavkzHJWp9WulBuzFOALqftBVY"
```

## 합격 기준
| 유형 | 합격 점수 |
|------|----------|
| 앱 아이콘 | 8점 이상 |
| 로고 | 8점 이상 |
| HTML UI 디자인 | 7점 이상 (전 항목) |
| UI 에셋 | 7점 이상 |
| 마케팅 배너 | 7점 이상 |
