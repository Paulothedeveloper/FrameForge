# FrameForge Brand Guidelines

## Logo & Identity

### Brand Story
**FrameForge** combines two powerful concepts:
- **Frame** → Video frames, frame rate, visual production
- **Forge** → To create, optimize, craft with precision and power

The logo represents speed, optimization, and professional video production.

---

## Logo Files

### Primary Logo
- `frameforge-icon.svg` - Full color symbol (Cinema Dark + Play Red)
- `frameforge-horizontal.svg` - Full lockup, wordmark in light text **(dark backgrounds only)**
- `frameforge-horizontal-light-bg.svg` - Same lockup, wordmark in Deep Indigo **(light/white backgrounds)**

### Monochrome Versions
- `frameforge-black.svg` - For light backgrounds
- `frameforge-white.svg` - For dark backgrounds (primary use)

---

## Logo Design Process (audited with the `logo-design` skill)

All four SVGs above were run through the skill's real tooling (`scripts/svg_audit.py`,
`scripts/render_png.py`, `scripts/preview_sheet.py`), not just written by hand. Findings and fixes:

| Check | Found | Fix |
|---|---|---|
| Optical centring (`frameforge-icon.svg`) | Margins L28/R44/T68/B76 (off-centre) | `translate(8,4)` → symmetric L36/R36/T72/T72. Score 94→97/100 |
| Optical centring (black/white monochrome) | Margins L28/R64/T68/B76 | `translate(18,4)` → symmetric L46/R46/T72/T72. Score →97/100 |
| Live `<text>` in `frameforge-horizontal.svg` | **FAIL**: wordmark used `<text>`/`<tspan>` — breaks if Poppins isn't installed on the viewer's machine | Rebuilt the wordmark as real outlined paths, extracted from the official Poppins Bold TTF (Google Fonts, SIL OFL) with `text-to-svg`. Score 71→96/100, FAIL cleared |
| Light-background readability | Rendering on white: **"Frame" (set in `#F8FAFC`) was nearly invisible** — the lockup was only ever tested visually against dark backgrounds | New `frameforge-horizontal-light-bg.svg` variant with "Frame" in `#1E1B4B`; verified side-by-side with `preview_sheet.py` at 96px/32px, one-colour and reversed |
| Missing `<title>` (accessibility) | All 4 files had none | Added `<title>FrameForge</title>` |
| 16px legibility | F silhouette stays legible; speed-trail lines, corner brackets and the velocity arc disappear at 16-32px (known, accepted trade-off) | None needed — the core mark (the F) is what must survive, and it does |

Remaining open items (INFO-level, not blocking): strokes are not yet expanded to filled outlines
(fine for digital use, matters for print/embroidery); the mark fills a modest % of its canvas.

## Color Palette

### Primary Colors

| Color | HEX | RGB | Use |
|-------|-----|-----|-----|
| **Play Red** | `#F84768` | `248, 71, 104` | Primary CTA, accents (WCAG AA: 5.47:1) |
| **Play Red Dark** | `#BE123C` | `190, 18, 60` | Hover states, gradients |
| **Cinema Dark** | `#0F0F23` | `15, 15, 35` | Primary dark, cards |
| **Deep Indigo** | `#1E1B4B` | `30, 27, 75` | Secondary dark, accents |

### Neutral Colors

| Color | HEX | RGB | Use |
|-------|-----|-----|-----|
| **Pure Black** | `#000000` | `0, 0, 0` | Background |
| **Almost White** | `#F8FAFC` | `248, 250, 252` | Text, icons |
| **Slate 400** | `#94A3B8` | `148, 163, 184` | Muted text |

### UI Colors

| Color | HEX | RGB | Use |
|-------|-----|-----|-----|
| **Success** | `#10B981` | `16, 185, 129` | Success states |
| **Warning** | `#F59E0B` | `245, 158, 11` | Warning states |

---

## Typography

### Headings
**Font:** Poppins  
**Weights:** 400 (Regular), 500 (Medium), 600 (Semi-Bold), 700 (Bold)  
**Usage:** Logos, titles, headings, buttons

### Body Text
**Font:** Open Sans  
**Weights:** 300 (Light), 400 (Regular), 500 (Medium), 600 (Semi-Bold), 700 (Bold)  
**Usage:** Paragraphs, UI text, descriptions

### Google Fonts Import
```css
@import url('https://fonts.googleapis.com/css2?family=Open+Sans:wght@300;400;500;600;700&family=Poppins:wght@400;500;600;700&display=swap');
```

---

## Logo Usage

### Minimum Size
- **Digital:** 32px height minimum
- **Favicon:** 16px (use simplified version if needed)
- **Print:** 0.5 inch height minimum

### Clear Space
Maintain clear space around logo equal to the height of the "F" in the mark.

### Dos
✅ Use on Cinema Dark or black backgrounds  
✅ Use white version on dark backgrounds  
✅ Use black version on light backgrounds  
✅ Maintain aspect ratio  
✅ Use provided SVG files  

### Don'ts
❌ Do NOT distort or skew  
❌ Do NOT change colors (except approved mono versions)  
❌ Do NOT add effects (shadows, glows, gradients)  
❌ Do NOT rotate  
❌ Do NOT place on busy backgrounds without container  

---

## Logo Concept

### Chosen Direction: Speed/Motion F-Mark

**Concept:** Letter F with dynamic speed trails and frame corner accents

**Why it works:**
- **Distinctive** - Speed trails are uncommon in dev tools (only 18/1432 logos use them)
- **Relevant** - Speed = optimization/performance; Frame corners = video production
- **Simple** - Works at 16px, one color, reversed
- **Memorable** - Clear motion/speed metaphor
- **Professional** - Geometric, bold, confident

**Design Principles Applied:**
- Round caps for approachability (not harsh corners)
- Bold stroke (28px on 256px canvas) for small-size strength
- Speed trails with varying opacity for depth
- Frame corners in secondary color (Cinema Dark) for video reference
- No gradients (only 19% of dev tools use them - easier to reproduce)

---

## Brand Adjectives

- **Powerful** → Bold strokes, strong F letterform
- **Fast** → Speed trails, motion effect
- **Technical** → Geometric construction, precise angles
- **Reliable** → Solid, stable form
- **Professional** → Clean, minimal, no ornament

---

## File Formats

All logos provided as:
- **SVG** (vector, scalable, recommended)
- Optimized for web use
- Clean, hand-coded paths
- No embedded fonts or rasters

---

## Credits

**Logo Design:** Professional workflow using logo-design skill  
**Design System:** ui-ux-pro-max + design-taste-frontend principles  
**Research:** 1,400+ logo library analysis  
**Color Strategy:** Cinema/video production theme

---

FrameForge
