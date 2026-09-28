# 02 — Design Document: Mana Pantalu

## 1. Design principles (from the deck)
1. **Next action is always obvious** — one primary button per screen.
2. **Telugu-first, English one tap away** — language toggle on Welcome and Profile.
3. **Voice as a peer of text** — every result/tip has a play button.
4. **Built for limited smartphone experience** — large targets, familiar icons, consistent way back.
5. **Calm** — no dashboards, no dense tables; short steps.

## 2. Visual language (derived from the deck's look)
- Mood: calm, natural, trustworthy; soft mint background, deep green actions.
- **Colors [ASSUMPTION: approximated from slides, tune with a color picker]**

| Token | Hex | Use |
|---|---|---|
| `bg` | `#F6FBF4` | Screen background |
| `surface` | `#E3F0E2` | Cards, chips |
| `primary` | `#2E6B3A` | Primary buttons, active nav |
| `primaryDark` | `#1F4D2A` | Headings, pressed |
| `onPrimary` | `#FFFFFF` | Text on primary |
| `text` | `#1B2B1F` | Body text |
| `textMuted` | `#5B6B5F` | Secondary text |
| `warning` | `#C77700` | Low confidence / weather alerts |
| `danger` | `#B3261E` | Errors |

- **Typography:** Noto Sans Telugu (Telugu) + Noto Sans (Latin), via `google_fonts`. Body **18sp minimum**, headings 24–28sp, buttons 20sp bold. Telugu needs slightly larger line height (1.5).
- **Shape:** 16dp card radius, 28dp button radius (pill), 2dp min elevation.
- **Touch targets:** min **56dp** height, 12dp minimum gap.
- **Icons:** Material Symbols (familiar): camera_alt, cloud, grass/eco, lightbulb, agriculture, person, mic, volume_up, arrow_back.
- **Imagery:** real farm photography on Welcome/crop cards; use placeholders in the prototype.

## 3. Navigation model
Persistent bottom nav (5 tabs), Telugu labels with icons:

| Tab | Telugu | English | Icon |
|---|---|---|---|
| 1 | హోమ్ | Home | home |
| 2 | పరీక్ష | Diagnose | camera_alt |
| 3 | నా పంటలు | My Crops | agriculture |
| 4 | సూచనలు | Tips | lightbulb |
| 5 | ప్రొఫైల్ | Profile | person |

Weather and Crop library are reached from Home tiles (not in the bottom nav). Back arrow always top-left; results screen back returns to Home.

## 4. Core interaction patterns
- **Voice button:** circular 56dp speaker icon; states idle / playing (animated) / unavailable (greyed + "install Telugu voice" hint).
- **Scan screen:** photo with a calm animated scan line and crop outline; no percent spinners.
- **Result card order:** (1) crop + issue name, (2) confidence chip, (3) voice play, (4) Symptoms, (5) Causes, (6) Prevention, (7) Care, (8) Treatment — each 2–4 short steps, (9) "Save" + "Scan again", (10) trust note.
- **Trust note** (persistent on result): "ఇది సూచన మాత్రమే. అనుమానం ఉంటే వ్యవసాయ అధికారిని సంప్రదించండి." (draft — native review needed)
- **Empty/error states:** each has an icon, one sentence, one button.
- **Accessibility:** contrast ≥ 4.5:1, semantic labels for screen readers, respect system font scale up to 1.3×.

## 5. Copy (draft Telugu — needs native review)
| Key | Telugu | English |
|---|---|---|
| welcome_title | మన పంటలకు స్వాగతం | Welcome to Mana Pantalu |
| start | ప్రారంభించండి | Start |
| take_photo | కెమెరాతో ఫోటో తీయండి | Take a photo with camera |
| pick_gallery | గ్యాలరీ నుంచి ఎంచుకోండి | Choose from gallery |
| scanning | పంటను పరిశీలిస్తోంది… | Checking your crop… |
| detected_crop | గుర్తించిన పంట | Detected crop |
| possible_issue | సాధ్యమైన సమస్య | Possible issue |
| not_sure | ఖచ్చితంగా చెప్పలేకపోతున్నాం | We are not sure |
| retake | మళ్ళీ ఫోటో తీయండి | Retake photo |
| ask_expert | నిపుణుడిని అడగండి | Ask an expert |
