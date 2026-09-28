# 05 — UI Wireframes & Component Hierarchy

Canvas: 360×800dp Android. `[ ]` = button, `( )` = icon, `[[ ]]` = card. Telugu is default; English shown for readability.

## Screen inventory
| ID | Screen | Route | Bottom nav visible |
|---|---|---|---|
| S1 | Welcome | `/welcome` | No |
| S2 | Home | `/home` | Yes |
| S3 | Diagnose – Capture | `/diagnose` | Yes |
| S4 | Diagnose – Scanning | `/diagnose/scan/:scanId` | No |
| S5 | Diagnose – Result | `/diagnose/result/:scanId` | No |
| S6 | Weather | `/weather` | Yes |
| S7 | Crop library | `/crops` | Yes |
| S8 | Crop detail | `/crops/:cropId` | Yes |
| S9 | Tips | `/tips` | Yes |
| S10 | My Crops | `/my-crops` | Yes |
| S11 | Add/Edit Crop | `/my-crops/new`, `/my-crops/:id/edit` | No |
| S12 | Profile | `/profile` | Yes |
| S13 | Feedback | `/profile/feedback` | No |
| S14 | Scan history | `/profile/history` | Yes |

## Wireframes

**S1 Welcome**
```
+--------------------------+
|        (logo) మన పంటలు    |
|  [ farm photo ]           |
|  మన పంటలకు స్వాగతం          |
|  AI farming support...    |
|  [ ప్రారంభించండి ]  (primary) |
|  ( తెలుగు | English )       |
+--------------------------+
```

**S2 Home** (six tiles, 2×3)
```
+--------------------------+
| మన పంటలు      (mic)(lang) |
| నమస్కారం!  (voice hello)   |
| [[ (camera) పరీక్ష     ]] [[ (cloud) వాతావరణం ]]
| [[ (grass) పంటలు      ]] [[ (bulb) సూచనలు   ]]
| [[ (agri) నా పంటలు    ]] [[ (help) సహాయం    ]]
| [[ Today's tip: ... (play) ]]
|--------------------------|
| హోమ్|పరీక్ష|నా పంటలు|సూచనలు|ప్రొఫైల్ |
+--------------------------+
```

**S3 Capture**
```
| <- పంట పరీక్ష                 |
| (voice) "ఒక ఆకును ఫ్రేమ్‌లో ఉంచండి" |
| [ guide frame illustration ]  |
| [ (camera) కెమెరాతో ఫోటో తీయండి ] |
| [ (gallery) గ్యాలరీ నుంచి ఎంచుకోండి ] |
| tips: good light, one leaf, close |
```

**S4 Scanning**
```
| [ photo with scan line + outline ] |
| పంటను పరిశీలిస్తోంది…               |
| [ రద్దు ]                          |
```

**S5 Result (done)**
```
| <- ఫలితం                               |
| [photo thumb]  గుర్తించిన పంట: వరి       |
| సాధ్యమైన సమస్య: ఆకుమచ్చ వ్యాధి [92%]      |
| [ (speaker) వినండి ]                    |
| ▸ లక్షణాలు  (steps 2-4)                 |
| ▸ కారణాలు                               |
| ▸ నివారణ                               |
| ▸ జాగ్రత్తలు                            |
| ▸ చికిత్స                              |
| [[ TRUST NOTE ]]                       |
| [ సేవ్ చేయండి ] [ మళ్ళీ స్కాన్ ]          |
| Was this helpful? (👍)(👎)               |
```
**S5 Result (low confidence)**: warning card "ఖచ్చితంగా చెప్పలేకపోతున్నాం", retake tips, `[ మళ్ళీ ఫోటో తీయండి ]` primary, `[ నిపుణుడిని అడగండి ]` secondary. No disease steps shown.

**S6 Weather**
```
| <- వాతావరణం   (location chip) |
| 31°C  మేఘావృతం                |
| [[ rain 60% ]][[ humidity 78% ]][[ wind 14 ]] |
| Alerts: [[ ⚠ రేపు వర్షం... (play) ]]  |
| 3-day strip                    |
```

**S9 Tips**: category chips (All / Crop care / Fertilizer / Irrigation / Pest) -> list of `TipCard` (title, 2 lines, play, save).

**S10 My Crops**: list of `MyCropCard` (crop, days since sowing, stage chip, next care action, reminder bell) + FAB-like large `[ + పంట జోడించండి ]`.

**S11 Add crop**: crop picker grid -> date picker (sowing date) -> field size (numeric stepper) -> location (use GPS / choose district) -> `[ సేవ్ ]`.

**S12 Profile**: language segmented toggle, notifications switch, location permission row, scan history, help, feedback, "Sign in with phone" (upgrade guest), app version.

**S13 Feedback**: big mic button (hold to record) or text field, `[ పంపండి ]`.

## Widget/Component hierarchy
```
MaterialApp.router (theme, l10n, router)
└─ AppShell (ShellRoute)                ← bottom nav
   ├─ AppBottomNav (5 destinations)
   └─ <child route>
Shared widgets (core/widgets):
  BigButton(primary|secondary), IconTile, SectionCard, ConfidenceChip,
  VoiceButton(text, lang), LanguageToggle, StepList(items), InfoBanner(kind),
  EmptyState(icon,text,cta), LoadingScan, ErrorRetry, AppScaffold(title, back)
Feature widgets:
  home: HomeScreen > GreetingHeader, HomeTileGrid > IconTile×6, TodayTipCard
  diagnose: CaptureScreen > FramingGuide, BigButton×2, PermissionRationale
            ScanScreen > ScanOverlay, CancelButton
            ResultScreen > ResultHeader, ConfidenceChip, VoiceButton,
                           ExpandableSection×5 > StepList, TrustNote, ResultActions, HelpfulRow
            LowConfidenceView > InfoBanner(warning), RetakeTips, BigButton×2
  weather: WeatherScreen > CurrentCard, MetricRow, AlertCard(VoiceButton), ForecastStrip
  crops: CropGrid > CropCard ; CropDetailScreen
  tips: TipsScreen > CategoryChips, TipCard(VoiceButton, SaveButton)
  my_crops: MyCropsScreen > MyCropCard ; AddCropScreen > CropPicker, DateField, NumberStepper, LocationPicker
  profile: ProfileScreen > SettingRow×n, LanguageToggle ; FeedbackScreen > RecordButton, TextField
```
