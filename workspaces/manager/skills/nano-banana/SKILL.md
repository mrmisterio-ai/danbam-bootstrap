---
name: nano-banana
description: Generate images using Google Gemini Native Image Generation (Nano Banana / Nano Banana Pro). Use when user requests image generation, app icons, marketing assets, illustrations, or visual content.
---

# Nano Banana Image Generation Skill

## Models

| Model | ID | 특징 | 비용 |
|-------|-----|------|------|
| **나노바나나** (일반) | `gemini-2.5-flash-image` | 빠르고 저렴, 기본 선택, 1024x1024 고정 | ~$0.03/이미지 |
| **나노바나나 Pro** | `gemini-3-pro-image-preview` | 고퀄, thinking, Google Search, 2K/4K | ~$0.13(2K), $0.24(4K) |
| **Imagen 4** | `imagen-4.0-generate-001` | predict API, 다양한 해상도 | TBD |
| **Imagen 4 Ultra** | `imagen-4.0-ultra-generate-001` | 최고 품질, predict API | TBD |

## 사용 전략
- **초안/시안**: 일반 모델 (`gemini-2.5-flash-image`) — 저렴하게 많이 시도
- **최종 에셋**: Pro 모델 (`gemini-3-pro-image-preview`) — 고퀄리티
- **API Key 전략**: 무료 키 먼저 시도 → 쿼터 초과 시 유료 키로 폴백

## API Keys
```bash
# 무료 (결제 미설정)
FREE_KEY="AIzaSyB2kUIBrkW4pKYq868USGbkdZI26jv1j6s"
# 유료 (Tier 1, pay-as-you-go)
PAID_KEY="AIzaSyBbx45pSjavkzHJWp9WulBuzFOALqftBVY"
```

## API 호출 방법

### 이미지 생성 (기본)
```bash
curl -s "https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{"parts": [{"text": "PROMPT"}]}],
    "generationConfig": {
      "responseModalities": ["TEXT", "IMAGE"]
    }
  }'
```

### 이미지만 생성 (텍스트 없이)
```json
"generationConfig": {
  "responseModalities": ["IMAGE"]
}
```

### 응답 파싱
```python
import json, base64
data = json.loads(response)
for part in data['candidates'][0]['content']['parts']:
    if 'inlineData' in part:
        img = base64.b64decode(part['inlineData']['data'])
        # Save to file
    elif 'text' in part:
        # Description text
```

### Pro 모델 — 2K/4K 해상도
```json
"generationConfig": {
  "responseModalities": ["TEXT", "IMAGE"],
  "imageGenerationConfig": {
    "outputImageSize": "2048"  
  }
}
```
- 2K: `"outputImageSize": "2048"`
- 4K: `"outputImageSize": "4096"` 

### 종횡비 설정
```json
"generationConfig": {
  "responseModalities": ["IMAGE"],
  "imageGenerationConfig": {
    "aspectRatio": "16:9"
  }
}
```
지원 비율: `1:1`, `3:4`, `4:3`, `9:16`, `16:9`

## 프롬프트 작성 가이드

### 필수 요소 (7가지)
1. **Subject**: 무엇/누가? (구체적으로)
2. **Composition**: 프레이밍 (close-up, wide shot, low angle 등)
3. **Action**: 무엇을 하고 있는지
4. **Location**: 어디서
5. **Style**: 미적 스타일 (3D, photorealistic, flat design, watercolor 등)
6. **Camera/Lighting**: 조명, 카메라 설정 (golden hour, shallow depth of field 등)
7. **Text Integration**: 텍스트가 필요한 경우 정확히 명시

### 프롬프트 템플릿

#### 앱 아이콘
```
Generate a mobile app icon for [앱이름]. 
Style: [modern/minimalist/3D/flat]. 
Shape: [rounded square/circle/hexagon]. 
Background: [color/gradient]. 
Main element: [description]. 
Color palette: [colors]. 
Aspect ratio: 1:1.
```

#### 스플래시/배너 이미지
```
Create a [horizontal/vertical] banner image for [purpose].
Style: [photorealistic/illustration/3D render].
Theme: [dark/light/vibrant].
Main subject: [description].
Text: "[exact text to render]" in [font style] at [position].
Aspect ratio: [16:9/9:16].
```

#### 마케팅 에셋 (앱스토어 스크린샷 배경)
```
Create a promotional background for a mobile app screenshot.
Style: [abstract gradient/geometric/lifestyle].
Color scheme: [brand colors].
Mood: [premium/energetic/calm].
Leave space in center for app screenshot overlay.
Aspect ratio: 9:16. Resolution: 4K.
```

#### 캐릭터/마스코트
```
Design a [cute/sleek/professional] mascot character for [brand].
Style: [3D render/2D vector/anime].
Character: [description].
Pose: [standing/waving/thinking].
Background: transparent/[color].
Maintain character consistency across generations.
```

### 프롬프트 팁
- **구체적일수록 좋음**: "a cat" ❌ → "a fluffy calico cat wearing a tiny wizard hat, sitting on an ancient leather-bound book" ✅
- **스타일 명시**: "photorealistic", "3D animation", "flat vector illustration", "watercolor" 등
- **텍스트 렌더링**: Pro 모델이 텍스트 렌더링에 훨씬 뛰어남 — 최종 에셋에 Pro 사용
- **이미지 편집**: 기존 이미지를 input으로 보내면 편집 가능 (inpainting, style transfer)
- **캐릭터 일관성**: 같은 세션(대화)에서 이전 이미지를 참조하면 일관성 유지
- **Pro만 가능**: thinking, Google Search 기반 정확한 다이어그램, 2K/4K, 14개 이미지 블렌딩

## 폴백 로직 (구현 시)
```
1. 무료 키로 시도
2. 429 (quota exceeded) → 유료 키로 재시도
3. 일반 모델 실패 → Pro 모델 시도 (최종 에셋만)
```

## 한계
- 텍스트 렌더링: 일반 모델은 부정확할 수 있음 (Pro 추천)
- 사실 정확성: 복잡한 다이어그램은 검증 필요
- 이미지 편집: 복잡한 편집은 여러 번 시도 필요
- Free Tier: 하루 요청 제한 있음 (빌링 미설정 시)
