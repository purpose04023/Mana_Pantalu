# 08 — State Management & User Flows

## 1. Approach
Riverpod (`AsyncNotifier` / `Notifier`), repository pattern, immutable `freezed` models. UI never calls Supabase directly. Errors are typed (`AppError`) and mapped to Telugu/English messages.

## 2. Providers
| Provider | Type | State | Persists |
|---|---|---|---|
| `envProvider` | Provider | env values | — |
| `supabaseClientProvider` | Provider | client | — |
| `sessionProvider` | StreamProvider | auth session / user id | Supabase |
| `localeProvider` | Notifier | `Locale('te'|'en')` | shared_prefs + profiles.language |
| `welcomeSeenProvider` | Notifier<bool> | | shared_prefs |
| `profileProvider` | AsyncNotifier | Profile | Supabase |
| `locationProvider` | AsyncNotifier | lat/lng or district | prefs + profile |
| `cropsProvider` | FutureProvider | List<Crop> | cache |
| `cropStagesProvider(cropId)` | FutureProvider.family | List<Stage> | cache |
| `weatherProvider` | AsyncNotifier | WeatherSnapshot + alerts | short cache (30 min) |
| `tipsProvider(category)` | FutureProvider.family | List<Tip> | cache |
| `savedTipsProvider` | AsyncNotifier | Set<tipId> | Supabase |
| `myCropsProvider` | AsyncNotifier | List<UserCrop> + computed stage | Supabase |
| `remindersProvider` | AsyncNotifier | List<Reminder> | Supabase + local notif |
| `capturedImageProvider` | Notifier | XFile? (temp) | — |
| `diagnoseControllerProvider` | Notifier<DiagnoseState> | see §3 | — |
| `scanResultProvider(scanId)` | FutureProvider.family | ScanResult | Supabase |
| `scanHistoryProvider` | AsyncNotifier | List<ScanSummary> | Supabase |
| `ttsControllerProvider` | Notifier<TtsState> | idle/playing/unavailable + current id | — |
| `feedbackControllerProvider` | Notifier | idle/recording/sending/sent/error | — |

Derived: `currentStageFor(userCrop)` = stage where `start_day <= today - sowing_date <= end_day`.

## 3. Diagnose state machine
```
idle ──pick(camera|gallery)──► picked(image)
picked ──confirm──► compressing ──► uploading ──► analyzing ──► success(done) | lowConfidence | error(kind)
error(kind) ──retry──► (uploading | analyzing, image kept)
any ──cancel──► idle
success | lowConfidence ──scanAgain──► idle
```
`DiagnoseState` (sealed): `Idle`, `Picked(file)`, `Working(step: compressing|uploading|analyzing)`, `Done(scanId)`, `LowConfidence(scanId)`, `Failure(AppError, retryable)`.
Timeout: `analyzing` > 30s -> Failure(timeout).

## 4. TTS state
`Idle -> Playing(itemId) -> Idle`; starting another item stops the current one. If `flutter_tts.isLanguageAvailable('te-IN')` is false -> `Unavailable` and every `VoiceButton` shows a hint "Install Telugu voice" (opens system TTS settings via intent, else message).
Text to speak = concatenated steps of the section or the whole result in order: crop, issue, symptoms, prevention, care, treatment, trust note.

## 5. User flows
**F-A First run**
`Splash -> (session ok) -> Welcome -> [Start] -> Home` (language chosen on Welcome; saved).

**F-B Photo diagnosis (happy path)**
`Home tile/Tab "పరీక్ష" -> Capture -> [Camera] -> (permission?) -> take photo -> preview [Use photo] -> Scan screen -> Result -> [Listen] -> [Save] -> Home`
Taps from Home: tile (1) -> camera (2) -> shutter (3) -> use photo (4) => result. ✔ matches goal ≤4.

**F-C Low confidence**
`Result(low) -> [Retake] -> Capture` or `[Ask expert] -> WhatsApp/phone intent`.

**F-D Error/offline**
`Analyzing fails -> ErrorRetry(msg, [Try again]) -> retry keeps image; [Cancel] -> Capture`.

**F-E Weather -> action**
`Home -> Weather -> alert card -> [Listen]`; if no location: `Weather -> LocationPicker(district) -> Weather`.

**F-F Add crop -> reminders**
`My Crops -> [+] -> pick crop -> sowing date -> size -> location -> Save -> My Crops (card shows stage + next action) -> reminder scheduled (local notification for next stage change)`.

**F-G Tips**
`Tips -> category chip -> TipCard -> [Play] / [Save]` ; saved tips reachable via filter "Saved".

**F-H Language switch**
`Profile or Welcome -> toggle -> localeProvider updates -> whole app rebuilds; profile.language synced`.

**F-I Feedback**
`Profile -> Feedback -> (hold mic | type) -> [Send] -> confirmation`.

**F-J Guest -> phone upgrade (optional)**
`Profile -> Sign in with phone -> enter number -> OTP -> linked; success banner`.

## 6. Error mapping
| AppError | Telugu message (draft) | UI |
|---|---|---|
| `NoNetwork` | ఇంటర్నెట్ లేదు | ErrorRetry |
| `Timeout` | ఎక్కువ సమయం పట్టింది, మళ్ళీ ప్రయత్నించండి | ErrorRetry |
| `RateLimited` | కొంత సేపటి తర్వాత ప్రయత్నించండి | InfoBanner |
| `PermissionDenied(camera)` | కెమెరా అనుమతి కావాలి | rationale + Open settings |
| `ImageTooLarge` | ఫోటో పెద్దగా ఉంది | auto-recompress |
| `Unknown` | ఏదో తప్పు జరిగింది | ErrorRetry |

## 7. Caching/offline (prototype level)
Cache crops, stages, tips, last weather, last 10 scan results in local storage; show cached data with a small "offline" chip. Diagnosis itself requires network (say so clearly).

## 8. Test cases to automate (give to Jules)
Provider unit tests: `currentStageFor` boundaries; alert rules thresholds; DiagnoseState transitions; locale switch persistence. Widget tests: Home shows 6 tiles; Result shows Low-confidence view when status=low_confidence; VoiceButton shows Unavailable state.
