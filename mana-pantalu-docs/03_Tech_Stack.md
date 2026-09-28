# 03 — Tech Stack: Mana Pantalu (prototype)

## 1. Decision summary
| Layer | Choice | Why |
|---|---|---|
| Mobile app | **Flutter (stable), Android first** | One codebase, camera/TTS/STT plugins, APK you can hand to farmers |
| State mgmt | **Riverpod** (`flutter_riverpod`) | Simple async state, testable, AI tools write it well |
| Routing | **go_router** | Declarative routes + redirects for guards |
| Backend | **Supabase** (Postgres, Auth, Storage, Edge Functions) | Free tier, RLS, no server to run |
| AI vision | **Gemini API** (Flash-class multimodal model; model name in env var) | Handles images and Telugu; key hidden in Edge Function |
| Weather | **Open-Meteo** (no API key, free for non-commercial use — verify terms if you commercialise) | Zero setup |
| Voice out (TTS) | `flutter_tts`, locale `te-IN` (on-device) | Free; needs Telugu voice installed on phone |
| Voice in (STT) | `speech_to_text`, locale `te-IN` | Free; quality varies by device |
| Local storage | `shared_preferences` (settings), `hive` or `drift` optional for cache | Keep light |
| Notifications | `flutter_local_notifications` | Prototype reminders; FCM later |
| Camera/gallery | `image_picker` + `flutter_image_compress` | Compress before upload |
| Location | `geolocator` + manual district fallback | GPS may be denied |
| i18n | Flutter `gen-l10n` with ARB files `app_te.arb`, `app_en.arb` | Telugu default |
| Fonts | `google_fonts` (Noto Sans Telugu) — bundle fonts for offline | Correct Telugu rendering |
| HTTP | `supabase_flutter` client + `dio` for Open-Meteo | |
| Models | `freezed` + `json_serializable` | Typed models |
| Testing | `flutter_test`, `mocktail` | Jules can write these |
| CI | GitHub Actions: `flutter analyze`, `flutter test` | |

## 2. Architecture
```
Flutter app (Android)
 ├─ UI (screens/widgets)  ← Riverpod providers
 ├─ Repositories: AuthRepo, ScanRepo, CropRepo, TipRepo, WeatherRepo, FeedbackRepo
 │     ├─ Supabase client  ──►  Postgres (RLS) / Storage (scans bucket)
 │     ├─ Supabase Edge Function  `diagnose`  ──►  Gemini API (key server-side)
 │     └─ Dio  ──►  Open-Meteo
 └─ Services: TtsService, SttService, NotificationService, LocationService
```

**Diagnosis pipeline (hybrid, safety-first):**
1. App compresses image (max ~1280px, JPEG q≈80, ≤1.5 MB) and uploads to Storage `scans/{uid}/{scanId}.jpg`.
2. App calls Edge Function `diagnose` with `scan_id`, `lang`, optional `crop_hint`.
3. Function downloads image, calls Gemini with a system prompt restricting output to the closed list of `crop_id` / `disease_id` from the DB and a JSON schema.
4. Function validates JSON, maps `disease_id` -> `diseases` row (localized symptoms/causes/prevention/care/treatment), applies confidence gate, writes result to `scans`, returns response.
5. App renders result and offers voice playback.

## 3. Folder structure (Flutter)
```
lib/
  main.dart
  app/            (app.dart, router.dart, theme.dart, env.dart)
  core/           (constants, errors, utils, widgets/)
  l10n/           (app_te.arb, app_en.arb)
  features/
    welcome/  home/  diagnose/  weather/  crops/  tips/  my_crops/  profile/  feedback/
      data/ (repositories, dto)  domain/ (models)  presentation/ (screens, widgets, providers)
  services/       (tts_service.dart, stt_service.dart, notification_service.dart, location_service.dart)
supabase/
  migrations/  functions/diagnose/index.ts  seed.sql
docs/  (this pack)
```

## 4. Build/deploy
- Local: `flutter run --dart-define-from-file=env.json`
- Edge Function: `supabase functions deploy diagnose`; secrets via `supabase secrets set GEMINI_API_KEY=...`
- APK: `flutter build apk --release`; share via link/WhatsApp for pilot.

## 5. Later (not prototype)
Offline-first cache & sync, FCM push, cloud Telugu TTS, on-device TFLite pre-check (leaf/not leaf), fine-tuned classifier on local data, admin/expert dashboard, iOS.

## 6. Cost notes
Prototype should fit free tiers (Supabase, Gemini free quota, Open-Meteo). Free-tier limits and terms change — check current limits before a pilot with many users.
