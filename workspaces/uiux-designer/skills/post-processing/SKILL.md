---
name: post-processing
description: |
  이미지 후가공 스킬. 배경 제거(누끼), SVG 벡터화, 리사이징.
  생성된 에셋을 프로덕션 투입 가능한 상태로 마감.
---

# Post-Processing — 이미지 후가공 스킬

## 도구 목록

### 1. Remove.bg — 배경 제거 (누끼)
```bash
curl -s -H "X-Api-Key: ${REMOVEBG_KEY}" \
  -F "image_file=@input.png" \
  -F "size=auto" \
  https://api.remove.bg/v1.0/removebg \
  -o output.png
```
- 무료: 50장/월 (저해상도)
- 유료: $9/40장 (고해상도)
- 용도: 캐릭터 이미지 누끼, 앱 아이콘 배경 투명화

### 2. Vectorizer.ai — PNG→SVG 벡터화
```bash
curl -s -u "api_id:api_secret" \
  -F "image=@input.png" \
  https://vectorizer.ai/api/v1/vectorize \
  -o output.svg
```
- API 테스트: 무료
- 유료: 종량제
- 용도: 로고, 아이콘 SVG 변환 (확대 시 깨지지 않음)

### 3. ImageMagick — 리사이징/포맷 변환 (로컬, 무료)
```bash
# 리사이징
convert input.png -resize 1024x1024 output.png

# 포맷 변환
convert input.png output.webp

# 앱 아이콘 여러 사이즈 생성
for size in 32 64 128 192 512 1024; do
  convert input.png -resize ${size}x${size} icon_${size}.png
done
```

### 4. 나노바나나 자체 편집 (무료, Gemini API)
```
# 기존 이미지를 보내면서 편집 요청
"이 이미지의 배경을 투명하게 만들어줘"
"이 이미지에서 텍스트만 제거해줘"
"이 이미지의 색상을 더 밝게 바꿔줘"
```
- 비용: 생성과 동일 (~$0.03~0.13)
- 한계: 정밀 편집은 전문 도구가 나음

## 에셋 유형별 후가공 체크리스트

### 앱 아이콘
- [ ] 1024×1024 원본 저장
- [ ] 512, 192, 128, 64, 32 사이즈 생성
- [ ] 배경 투명 버전 생성
- [ ] iOS (둥근 모서리) / Android (Adaptive Icon) 확인
- [ ] 앱스토어 미리보기 (밝은/어두운 배경에서)

### 로고
- [ ] PNG 고해상도 원본
- [ ] SVG 벡터 변환 (필수)
- [ ] 배경 투명 버전
- [ ] 단색(흑/백) 버전
- [ ] 가로형 / 정사각형 / 아이콘형 변형

### 마케팅 배너
- [ ] 원본 해상도 저장
- [ ] 앱스토어 스크린샷 규격 (1290×2796 iPhone, 1284×2778)
- [ ] 소셜 미디어 규격 (1200×630 OG, 1080×1080 인스타)
- [ ] WebP 변환 (웹 최적화)
