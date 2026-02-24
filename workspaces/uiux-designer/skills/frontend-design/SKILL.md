---
name: frontend-design
description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, artifacts, posters, or applications. Generates creative, polished code and UI design that avoids generic AI aesthetics.
license: Complete terms in LICENSE.txt
---

This skill guides creation of distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Implement real working code with exceptional attention to aesthetic details and creative choices.

## Design Thinking

Before coding, understand the context and commit to a BOLD aesthetic direction:
- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Pick an extreme aligned with the project. For TFT Agent → refined gaming luxury. For SI 외주 → client brand에 맞는 톤. For 대시보드 → developer-centric, data-dense.
  - Possible directions: brutally minimal, maximalist, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco, soft/pastel, industrial — 매번 다른 방향을 시도하라.
- **Constraints**: Technical requirements (framework, performance, accessibility).
- **Differentiation**: What makes this UNFORGETTABLE? What's the one thing someone will remember?

**CRITICAL**: Choose a clear conceptual direction and execute it with precision. The key is intentionality, not intensity.

**VARIETY**: No two projects should look the same. Vary themes, fonts, color palettes, layout strategies. NEVER converge on the same visual identity across different projects. Each project deserves its own personality.

**MATCH COMPLEXITY TO VISION**: Maximalist designs need elaborate code with extensive animations and effects. Minimalist designs need restraint, precision, and careful attention to spacing and subtle details. Elegance = executing the vision well.

## Frontend Aesthetics Guidelines

### Typography
- **NEVER** use generic fonts: Arial, Inter, Roboto, system fonts, Space Grotesk
- **Display font**: Use bold, distinctive fonts — Outfit, Exo 2, Rajdhani, Orbitron (gaming feel)
- **Body font**: Pretendard (Korean), Outfit or DM Sans (English)
- **Numbers/Stats**: Use tabular figures, monospace feel — JetBrains Mono, Space Mono for stats
- Load via Google Fonts CDN: `<link href="https://fonts.googleapis.com/css2?family=...&display=swap">`

### Color & Theme
- Commit to a cohesive aesthetic. Use CSS variables for consistency.
- Dominant colors with sharp accents outperform timid, evenly-distributed palettes.
- **TFT Agent palette**: Deep navy base (#0a0e1a), subtle blue-teal accents, gold highlights for premium elements
- **Avoid**: Pure black (#000), pure white (#fff) — use off-blacks and off-whites

### Icons — CRITICAL
- **NEVER use emoji as UI icons** (🏠❌, ⚙️❌, ⭐❌)
- **ALWAYS use inline SVG icons** from professional libraries
- **Primary: Phosphor Icons** — https://phosphoricons.com/ (9,000+ icons, 6 styles)
- **Alternative: Lucide** — https://lucide.dev/ (1,500+ clean icons)
- Embed icons as inline SVG directly in HTML (no external dependencies needed)
- Example tab bar icons (Phosphor bold style):
  ```html
  <!-- Home -->
  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 256 256"><path d="M219.31,108.68l-80-80a16,16,0,0,0-22.62,0l-80,80A15.87,15.87,0,0,0,32,120v96a8,8,0,0,0,8,8H216a8,8,0,0,0,8-8V120A15.87,15.87,0,0,0,219.31,108.68Z" fill="currentColor"/></svg>
  <!-- Trophy/Meta -->
  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 256 256"><path d="M232,64H208V48a8,8,0,0,0-8-8H56a8,8,0,0,0-8,8V64H24A16,16,0,0,0,8,80V112a40,40,0,0,0,40,40h4.17A64.11,64.11,0,0,0,96,192v16H72a8,8,0,0,0,0,16H184a8,8,0,0,0,0-16H160V192a64.11,64.11,0,0,0,43.83-40H208a40,40,0,0,0,40-40V80A16,16,0,0,0,232,64Z" fill="currentColor"/></svg>
  ```
- Use `currentColor` fill so icons inherit text color
- Size: 24px for tab bar, 20px for inline, 16px for small

### Motion & Micro-interactions
- Use CSS animations for high-impact moments
- Staggered reveals on page load (animation-delay)
- Smooth tab transitions (transform + opacity)
- Card hover: subtle lift (translateY -2px) + shadow increase
- Tab active state: smooth color transition + indicator slide
- Pull-to-refresh, skeleton loading states

### 2026 Design Trends — APPLY THESE

1. **Glassmorphism** (핵심!)
   - Frosted glass cards: `backdrop-filter: blur(12px); background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.08);`
   - Use on floating cards, modals, bottom sheets
   - Don't overuse — 1-2 glassmorphism elements per screen

2. **Subtle Gradients & Glow**
   - Accent borders with gradient: `border-image: linear-gradient(135deg, #C8AA6E, #2a7fff) 1;`
   - Neon glow on active elements: `box-shadow: 0 0 20px rgba(42,127,255,0.3);`
   - Background: subtle radial gradient from center, not flat color

3. **Noise/Grain Texture**
   - Add subtle noise overlay to backgrounds for depth
   - CSS: `background-image: url("data:image/svg+xml,...noise...")` or CSS filter

4. **Micro-interactions**
   - Every tap should have feedback (scale, color, haptic feel)
   - Skeleton loading instead of spinners
   - Animated number counters for stats

5. **Layered Depth**
   - Multiple elevation levels: base → card → floating → modal
   - Each level has different shadow + background opacity
   - Creates spatial hierarchy without borders

6. **Premium Dark Mode**
   - NOT flat black — use gradient backgrounds
   - Subtle vignette effect on edges
   - Warm gold (#C8AA6E) + cool blue (#2a7fff) accent pairing
   - Text hierarchy: bright white (titles) → muted gray (body) → dim (secondary)

### Spatial Composition
- Generous padding (16-24px)
- Card corner radius: 12-16px (modern, not too rounded)
- Consistent spacing scale: 4, 8, 12, 16, 24, 32, 48px
- Touch targets: minimum 44×44px

### Backgrounds & Visual Details
- Create atmosphere and depth rather than flat solid colors
- Background: radial gradient from subtle accent color
- Add contextual effects: noise textures, geometric patterns, layered transparencies
- Dramatic shadows for elevated elements
- Section dividers: gradient lines, not solid borders

## Quality Checklist — EVERY SCREEN

Before delivering, verify:
- [ ] Zero emoji icons — all SVG
- [ ] Custom fonts loaded (not system fonts)
- [ ] Glassmorphism applied to key cards
- [ ] Micro-animations on interactive elements
- [ ] Consistent spacing (8px grid)
- [ ] Color variables used (not hardcoded)
- [ ] Stats numbers in monospace/tabular font
- [ ] Touch targets ≥ 44px
- [ ] Skeleton loading states
- [ ] Gradient accents (not flat borders)

## NEVER Do This
- ❌ Emoji as icons
- ❌ System/generic fonts
- ❌ Flat solid backgrounds without depth
- ❌ Hard borders (1px solid #333) without gradient or glow
- ❌ Cookie-cutter layouts
- ❌ Static elements with no hover/active states
- ❌ Spinner loading (use skeleton)
- ❌ Rainbow gradients or overly colorful cards
