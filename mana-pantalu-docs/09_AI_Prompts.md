# 09 — AI Prompts (feed these to Antigravity / Cursor / Jules / Lovable)

## 0. How to use
1. Put all docs in `/docs`. Put §1 (`AGENTS.md`) in the repo root (Cursor: also copy to `.cursor/rules`; Antigravity/Jules read `AGENTS.md`).
2. Run prompts **A → E in order**, one per session. After each, run the app on a phone, fix, commit, then continue.
3. If the AI drifts, paste: *"Re-read /docs/<file> and fix only the differences. Do not change anything else."*

## 1. `AGENTS.md` (repo root)
```
# Mana Pantalu — rules for AI agents
Product: Telugu-first AI farming app (Flutter, Android). Specs live in /docs — they are the source of truth. Read the relevant doc before coding a feature.
Stack: Flutter stable, Riverpod, go_router, supabase_flutter, freezed, flutter_tts, image_picker, geolocator, dio, flutter_local_notifications.
Rules:
- Telugu is the default language; every user-facing string goes in lib/l10n/app_te.arb and app_en.arb. No hard-coded UI strings.
- Accessibility: min 56dp touch targets, body text >= 18sp, contrast >= 4.5:1, semantic labels.
- No API keys in the app. Gemini is called only from the Supabase Edge Function.
- AI must never generate treatment/dosage text; treatment comes from the `diseases` table.
- UI never calls Supabase directly; go through repositories + Riverpod providers.
- Keep files small; follow the folder structure in docs/03_Tech_Stack.md.
- After each task: run `flutter analyze` and `flutter test`; fix all issues. Do not add packages not listed without asking.
- Do not refactor unrelated code. Commit-sized changes only.
- If a spec is ambiguous, choose the simplest option and list it under "Assumptions" in your final message.
```

## 2. Prompt A — Project scaffold
```
Read /docs/03_Tech_Stack.md, /docs/02_Design_Document.md, /docs/06_Auth_and_Route_Permissions.md and /docs/08_State_Management_and_User_Flows.md.
Create the Flutter project (Android only) in the repo with the folder structure from doc 03.
Implement: theme from doc 02 (colors, Noto Sans Telugu via google_fonts, 56dp buttons); gen-l10n with app_te.arb (default) and app_en.arb containing the copy table in doc 02; env loading via --dart-define-from-file (env.example.json); Supabase init; anonymous sign-in on start; go_router with the redirect rules from doc 06 and a ShellRoute with the 5-tab bottom nav (హోమ్, పరీక్ష, నా పంటలు, సూచనలు, ప్రొఫైల్); shared widgets: BigButton, IconTile, SectionCard, VoiceButton (UI only), LanguageToggle, InfoBanner, EmptyState, ErrorRetry, AppScaffold.
All screens exist as placeholders with correct routes from doc 05. localeProvider switches language live.
Done when: app runs, navigates all tabs, language toggle works, flutter analyze is clean.
```

## 3. Prompt B — Static screens with seed/mock data
```
Read /docs/05_UI_Wireframes_and_Component_Hierarchy.md, /docs/04_Database_Schema_and_Mock_Data.md, /docs/02_Design_Document.md.
Build screens S1, S2, S6, S7, S8, S9, S10, S11, S12, S13, S14 exactly per the wireframes and widget hierarchy. Use repositories with an in-memory mock implementation (data from doc 04 §3-4) behind an interface so I can swap in Supabase later. Weather uses the mock snapshot for now.
Implement My Crops stage calculation (currentStageFor) and unit tests for its boundaries.
Do NOT build the diagnose screens yet.
Done when: every listed screen is reachable, looks like the wireframe, works in Telugu and English, and tests pass.
```

## 4. Prompt C — Diagnose flow (fake backend)
```
Read /docs/05 (S3, S4, S5), /docs/08 (§3 Diagnose state machine, §5 flows, §6 errors) and /docs/07 (§1 contract, §5 fake diagnose).
Implement the full diagnose flow: capture (camera/gallery with permission handling), image compression (max 1280px, JPEG ~80), scanning screen with animated scan line, result screen (confident view and low-confidence view), save, scan again, helpful vote, and error/retry states.
Use FEATURE_FAKE_DIAGNOSE=true: ScanRepo.diagnose returns the mock result after 2.5s; every 3rd call returns low-confidence.
Implement DiagnoseController exactly as the state machine. Add widget tests for both result views.
Done when: I can go Home -> photo -> result in <=4 taps and see both result types.
```

## 5. Prompt D — Real backend (Supabase + Gemini)
```
Read /docs/04, /docs/06, /docs/07.
1) Create supabase/migrations/0001_init.sql from doc 04 (schema, RLS, storage policies, seed).
2) Write the Edge Function supabase/functions/diagnose/index.ts (Deno/TypeScript) implementing doc 07 §1 exactly: JWT verification, ownership check, rate limit using the scans table, image fetch, closed-list loading, Gemini call (system prompt from doc 09 §8, JSON response schema), validation, confidence gate, DB update with service role, localized response, all error codes.
3) Implement SupabaseScanRepo (upload image, insert pending scan, call function, fetch result), SupabaseCropRepo, TipRepo, MyCropRepo, ProfileRepo, FeedbackRepo. Switch off FEATURE_FAKE_DIAGNOSE.
4) Add a README section with deploy commands and required secrets.
Never put keys in code. Done when a real photo produces a stored, correct result and a bad image produces low_confidence.
```

## 6. Prompt E — Voice, weather, reminders
```
Read /docs/03, /docs/07 §3, /docs/08 §4.
1) TtsService with flutter_tts: te-IN / en-IN, Playing/Idle/Unavailable states, one item at a time; wire VoiceButton on results, tips, weather alerts. If Telugu voice is missing show the hint from doc 08.
2) Real weather from Open-Meteo per doc 07 §3 with client-side alert rules, 30-min cache, district fallback (assets/districts.json for AP/Telangana districts).
3) Local reminders with flutter_local_notifications: schedule a reminder for the next crop stage change when a crop is saved; handle Android 13+ notification permission.
4) Voice-note feedback (hold-to-record) OR text-only if recording is unreliable; keep text as fallback.
Done when: results/tips/alerts can be heard in Telugu on a real device, weather is live, and a reminder fires.
```

## 7. Prompt F — Jules tasks (after code is on GitHub; run in parallel)
- "Add widget and unit tests for providers and screens listed in docs/08 §8. Do not change app code except for testability."
- "Audit lib/ for hard-coded strings and move them to app_te.arb/app_en.arb."
- "Run flutter analyze; fix all warnings without changing behaviour."
- "Add a GitHub Actions workflow: flutter analyze + flutter test on PRs."

## 8. Gemini system prompt for the `diagnose` function (§8 reference)
```
You are a plant-health image classifier for an agriculture app used by Indian farmers.
Look at the photo and answer ONLY with JSON matching the schema.

Supported crops: {CROP_IDS}
Supported diseases (id -> crop): {DISEASE_LIST}

Rules:
- Choose crop_id from the supported crops, or "unknown" if the plant is not one of them or is not clearly visible.
- Choose disease_id from the supported diseases for that crop, or "healthy" if no problem is visible, or "unknown" if you cannot tell or the problem is not in the list.
- Never invent ids. Never give treatment advice or chemicals.
- confidence is your honest 0.0-1.0 estimate. Use low values when the photo is blurry, dark, far away, shows several plants, or shows symptoms that could be nutrient deficiency, pests or more than one disease.
- image_quality is "poor" if blurry, dark, no leaf in focus, or the subject is too small; otherwise "good".
- visible_symptoms: one short English sentence describing what you see.

Schema: {"crop_id": string, "disease_id": string, "confidence": number, "image_quality": "good"|"poor", "visible_symptoms": string}
```
(The function fills `{CROP_IDS}` and `{DISEASE_LIST}` from the DB at request time.)

## 9. Prompt for a quick web demo (Lovable / free web builders)
```
Build a mobile-first web app (max width 420px, PWA) called "Mana Pantalu" — Telugu-first AI farming assistant. Use Supabase for data. Follow: 5-tab bottom nav (హోమ్, పరీక్ష, నా పంటలు, సూచనలు, ప్రొఫైల్), Home with 6 large tiles, a Diagnose flow (choose/take photo -> scanning animation -> result with crop, possible issue, confidence chip, symptoms/prevention/care/treatment lists, speaker button using the browser SpeechSynthesis with te-IN, low-confidence state), Weather (Open-Meteo), Tips, My Crops, Profile with te/en toggle. Colors: bg #F6FBF4, cards #E3F0E2, primary #2E6B3A. Min 56px buttons, 18px text. Use mock diagnosis result for now. Copy and data are in the attached docs.
```
