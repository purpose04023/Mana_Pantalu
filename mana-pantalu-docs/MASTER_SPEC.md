# Mana Pantalu (మన పంటలు) — Prototype Document Pack

Source: `Mana_Pantalu.pptx` (11 slides). Everything here is derived from that deck; where the deck was silent I made a decision and marked it **[ASSUMPTION]** so you can change it.

## 1. What "prototype" means here (scope lock)

Goal: a phone app you can demo to farmers, mentors, judges or an agriculture officer where **one thing is real: photo -> diagnosis -> Telugu voice/text guidance**. Everything else can be light or mocked.

| Real in prototype | Mocked / light in prototype |
|---|---|
| Camera/gallery photo -> AI diagnosis (Gemini) | Treatment content: small hand-written table for ~4 crops |
| Telugu/English switch, Telugu voice playback | Push notifications (local reminders only) |
| Live weather (Open-Meteo, free) | Expert confirmation (button shows "coming soon" / WhatsApp link) |
| Save crops, scan history, feedback | Fertilizer/irrigation logic (rule-based tips from a table) |

## 2. Best tool to build it (my honest recommendation)

**Primary: Flutter + Supabase + Gemini API, built with an AI IDE (Google Antigravity or Cursor) reading this doc pack from a `/docs` folder.**
Why: the app depends on camera, text-to-speech, speech input, local notifications and an AI call with an image. That is custom-code territory, and Flutter gives one Android APK you can install on a farmer's phone. Supabase gives auth, database, image storage and a server function (to hide the Gemini key) on a free tier.

| Tool | Use it for | Verdict |
|---|---|---|
| **Antigravity / Cursor (Flutter)** | Main build, all phases | Best |
| **Jules** | After the repo is on GitHub: async tasks like "add ARB Telugu strings", "write widget tests", "fix analyzer warnings" | Good helper, not the main builder |
| **FlutterFlow** | Drag-drop screens if you don't want code | Weak fit: voice, camera flow and the Edge Function need custom code, and code export/limits depend on your plan (check current pricing) |
| **Lovable / free web builders** | A 1-day clickable web demo (PWA) if you need something to show *this week* | Fine as a throwaway; browser camera/TTS in Telugu is less reliable than native |

If you must pick one path today: **Flutter + Supabase + Gemini**.

## 3. Step-by-step build process

**Phase 0 — Prep (half day)**
1. Create a GitHub repo `mana-pantalu`. Create folder `/docs` and drop all files from this pack in it.
2. Create Supabase project. Get a Gemini API key from Google AI Studio.
3. Collect **30–50 real photos** of rice/cotton/chilli/groundnut leaves (ANGRAU/KVK contacts, farmers, or the public PlantVillage dataset for a start). You need these to test diagnosis honestly.

**Phase 1 — Backend foundation (half day)**
4. Run the SQL from `04_Database_Schema_and_Mock_Data.md` (schema, RLS, seed). Create Storage bucket `scans`.
5. Enable **Anonymous sign-ins** in Supabase Auth (guest-first login, see doc 06).

**Phase 2 — App shell (1 day)**
6. Give the AI `AGENTS.md` (in doc 09) + Prompt A. Result: Flutter project, theme, routing, 5-tab bottom nav, English/Telugu switch, empty screens.

**Phase 3 — Static screens with mock data (1–2 days)**
7. Prompt B: Welcome, Home (6 tiles), Weather, Crop library, Tips, My Crops, Profile. Use seed data only. Review on a real phone: touch targets, font size, Telugu rendering.

**Phase 4 — The core feature (2 days)**
8. Prompt C: Diagnose flow UI with a **fake** `diagnose` response so the whole flow works offline.
9. Deploy Edge Function `diagnose` (Prompt D) and switch the app from fake to real. Test with your 30–50 photos; record how often it's right. Tune the prompt and the confidence threshold.

**Phase 5 — Voice, reminders, feedback (1 day)**
10. Prompt E: Telugu TTS playback on results and tips; voice-note feedback; local reminders for My Crops.

**Phase 6 — Test and ship (1–2 days)**
11. Build APK, install on 2–3 low-end Android phones, and watch 3–5 real farmers use it **without helping**. Note where they hesitate. Fix the top 5 problems. That feedback is worth more than any extra feature.

## 4. Getting more out of it (beyond code)

- **Accuracy is the make-or-break.** Field photos (bad light, multiple leaves, mixed problems) are much harder than clean dataset photos. Measure it and show the number.
- **Don't let the AI invent treatments.** This pack uses a hybrid: Gemini only *identifies* crop + disease from a fixed list (or says "unknown"); the *treatment text* comes from a table your agriculture expert verifies. This is the difference between a demo and something safe to put in front of farmers.
- **Get one expert.** A local Krishi Vigyan Kendra (KVK) scientist, ANGRAU extension officer or Rythu Bharosa Kendra staff member to verify content. They are also your best pilot channel.
- **Telugu copy must be reviewed by a native, farm-literate speaker.** Telugu strings in this pack are drafts.
- **Be honest in the UI:** "possible issue", confidence shown, low confidence -> "ask an expert". The deck already says this; keep it.

## 5. Document map (answers to your list)

| # | File | What it is |
|---|---|---|
| 01 | `01_PRD.md` | Product Requirements |
| 02 | `02_Design_Document.md` | Visual design system + UX principles |
| 03 | `03_Tech_Stack.md` | Stack and why |
| 04 | `04_Database_Schema_and_Mock_Data.md` | SQL schema, RLS, seed data |
| 05 | `05_UI_Wireframes_and_Component_Hierarchy.md` | Screens, ASCII wireframes, widget tree |
| 06 | `06_Auth_and_Route_Permissions.md` | Auth model, routes, RLS matrix |
| 07 | `07_API_Contracts_and_Env_Vars.md` | Endpoints, JSON contracts, env vars |
| 08 | `08_State_Management_and_User_Flows.md` | Riverpod providers, flows, state machines |
| 09 | `09_AI_Prompts.md` | AGENTS.md, build prompts A–E, Gemini system prompt |
| — | `MASTER_SPEC.md` | All of the above in one file, for tools with one context box |

**How to feed the AI:** put the files in `/docs`, tell the AI to read them first, then give it **one phase prompt at a time** (doc 09). Don't paste everything and say "build the app" — results get worse the bigger the single ask.
# 01 — Product Requirements Document (PRD): Mana Pantalu

## 1. Summary
Mana Pantalu is a Telugu-first, voice-friendly AI farming assistant. A farmer photographs a crop leaf, the app identifies the possible disease, explains it in simple Telugu (text + voice), and gives care, prevention and treatment guidance. Supporting features: weather, crop info, daily tips, saved crops with reminders, and feedback.

## 2. Problem
Farmers lose crops when diseases are noticed late. Without quick, understandable guidance it is hard to know what is affecting a crop and what to do.

## 3. Target users
- **Primary:** small/marginal farmers in Andhra Pradesh/Telangana, Telugu speakers, limited smartphone experience, low-to-mid-range Android, sometimes weak connectivity, sometimes low reading comfort.
- **Secondary (later):** farmer's family member who helps with the phone; agriculture extension officers.

## 4. Goals (prototype)
1. A first-time user reaches a diagnosis result in **≤ 4 taps** from opening the app.
2. Result is understandable **without reading** (voice playback).
3. Correct top-1 crop+disease on a test set of real photos (target to be measured; report the actual number).
4. App fully usable in Telugu; English one tap away.

## 5. Non-goals (prototype)
Payments/marketplace, community/social, iOS, admin dashboard, offline-first sync, real push notifications, real expert chat, pesticide purchase links, multi-disease-per-image analysis.

## 6. Features and requirements
Priority: **P0** must ship in prototype, **P1** should, **P2** later.

| ID | Feature | Requirement | Pri |
|---|---|---|---|
| F1 | Welcome & language | First launch shows Telugu welcome + "Start" button and English toggle. Choice saved. | P0 |
| F2 | Home | Six large tiles: Diagnose, Weather, Crops, Tips, My Crops, Help/Feedback **[ASSUMPTION: deck says "six routes" without naming them]**. Persistent bottom nav. | P0 |
| F3 | Photo diagnosis — capture | Buttons: take photo (camera) / choose from gallery. Short voice+text prompt on how to frame one leaf. Handle permission denial gracefully. | P0 |
| F4 | Photo diagnosis — scan | Animated "scanning" state with text "పంటను పరిశీలిస్తోంది…"; cancel; timeout 30s with retry. | P0 |
| F5 | Disease result | Shows detected crop, possible issue, confidence %, symptoms, causes, prevention, care, treatment as short steps; voice playback; save to history. | P0 |
| F6 | Low-confidence handling | Confidence < threshold (default 0.60), or image poor, or "unknown" -> show "Not sure" state, retake tips, and "ask an expert" button. Never show a confident-looking diagnosis. | P0 |
| F7 | Crop library | Grid of ~8 common crops with photo/icon, name (te/en), basic info. | P1 |
| F8 | Weather | Current temp, rain chance, humidity, wind, 3-day summary for saved location; plain-language alert cards (e.g., "rain expected — delay spraying"). | P0 |
| F9 | Daily tips | Cards by category (crop-care, fertilizer by stage, irrigation+weather, pest prevention); text + voice; save & replay. | P0 |
| F10 | My Crops | Add crop with sowing date, field size, location; shows current growth stage and next care action; reminders. | P0 |
| F11 | Profile | Language, notifications toggle, location permission, help, sign-in upgrade (phone). | P0 |
| F12 | Feedback | Text or voice note to team. | P1 |
| F13 | Voice input | Speak instead of type in feedback/search (te-IN). | P1 |
| F14 | Scan history | List of past scans with result and date. | P1 |
| F15 | Expert confirmation | Button opens a WhatsApp/phone link to a configured helpline number **[ASSUMPTION]**. | P2 |

## 7. Content rules (safety)
- AI identifies only from a **closed list** of supported crops/diseases; otherwise returns `unknown`.
- Treatment/dosage text comes from an **expert-verified table**, never free-generated by the model. Prototype seed content is marked `expert_verified = false` and the UI shows a small "guidance only — confirm with your agriculture officer" note.
- Always say "possible" issue. Show confidence.

## 8. Success metrics (pilot)
Time to first result; % scans completed; % results where voice was played; user-reported "was this helpful" (👍/👎 on result); diagnosis accuracy vs expert label; day-7 return rate.

## 9. Risks
| Risk | Mitigation |
|---|---|
| Wrong diagnosis harms crop | Closed set, confidence gate, expert-verified treatments, disclaimer |
| Telugu TTS voice missing on device | Detect; fallback to text + prompt to install Google TTS Telugu voice; optional cloud TTS later |
| Poor connectivity | Compress image before upload; clear retry; cache last results/tips |
| Low digital literacy | Big targets, icons + voice, no typing required, guest login |
| API cost/abuse | Rate limit per user on Edge Function; image size cap |

## 10. Open questions
Which districts/crops first? Which expert/KVK verifies content? Helpline number? Do you want phone-OTP login in the prototype or guest-only?
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
# 04 — Database Schema & Mock Data (Supabase / Postgres)

Run in Supabase SQL editor (or as `supabase/migrations/0001_init.sql`). Create Storage bucket `scans` (private).

## 1. Schema
```sql
create extension if not exists "pgcrypto";

-- Users' profile (1:1 with auth.users, incl. anonymous users)
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  language text not null default 'te' check (language in ('te','en')),
  district text,
  latitude double precision,
  longitude double precision,
  notifications_enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Master data (read-only for app users)
create table public.crops (
  id text primary key,                 -- 'rice','cotton',...
  name_te text not null,
  name_en text not null,
  icon text,                           -- asset name
  description_te text,
  description_en text,
  duration_days int                    -- approx. season length, used for stage calc
);

create table public.crop_stages (
  id uuid primary key default gen_random_uuid(),
  crop_id text not null references public.crops(id) on delete cascade,
  stage_order int not null,
  name_te text not null,
  name_en text not null,
  start_day int not null,              -- days after sowing
  end_day int not null,
  care_action_te text not null,
  care_action_en text not null,
  unique (crop_id, stage_order)
);

create table public.diseases (
  id text primary key,                 -- 'rice_brown_spot'
  crop_id text not null references public.crops(id) on delete cascade,
  name_te text not null,
  name_en text not null,
  symptoms_te text[] not null default '{}',
  symptoms_en text[] not null default '{}',
  causes_te text[] not null default '{}',
  causes_en text[] not null default '{}',
  prevention_te text[] not null default '{}',
  prevention_en text[] not null default '{}',
  care_te text[] not null default '{}',
  care_en text[] not null default '{}',
  treatment_te text[] not null default '{}',
  treatment_en text[] not null default '{}',
  expert_verified boolean not null default false,
  source_note text
);

create table public.tips (
  id uuid primary key default gen_random_uuid(),
  crop_id text references public.crops(id) on delete set null,  -- null = general
  category text not null check (category in ('crop_care','fertilizer','irrigation_weather','pest_prevention')),
  title_te text not null, title_en text not null,
  body_te text not null,  body_en text not null,
  stage_order int,                     -- optional: show at this stage
  created_at timestamptz not null default now()
);

-- User data
create table public.user_crops (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  crop_id text not null references public.crops(id),
  sowing_date date not null,
  field_size_acres numeric(8,2),
  location_text text,
  created_at timestamptz not null default now()
);
create index on public.user_crops(user_id);

create table public.scans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  image_path text not null,            -- storage path in bucket 'scans'
  status text not null default 'pending' check (status in ('pending','done','low_confidence','failed')),
  crop_id text references public.crops(id),
  disease_id text references public.diseases(id),
  confidence numeric(4,3),
  image_quality text check (image_quality in ('good','poor')),
  raw_model_output jsonb,
  language text not null default 'te',
  helpful boolean,                     -- 👍/👎 feedback
  created_at timestamptz not null default now()
);
create index on public.scans(user_id, created_at desc);

create table public.saved_tips (
  user_id uuid not null references public.profiles(id) on delete cascade,
  tip_id uuid not null references public.tips(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, tip_id)
);

create table public.reminders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  user_crop_id uuid references public.user_crops(id) on delete cascade,
  title text not null,
  remind_at timestamptz not null,
  done boolean not null default false
);

create table public.feedback (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  kind text not null check (kind in ('text','voice')),
  message text,
  audio_path text,                     -- bucket 'feedback' (optional)
  created_at timestamptz not null default now()
);

-- Auto-create profile on signup (incl. anonymous)
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id) values (new.id) on conflict do nothing;
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();
```

## 2. Row Level Security
```sql
alter table public.profiles    enable row level security;
alter table public.user_crops  enable row level security;
alter table public.scans       enable row level security;
alter table public.saved_tips  enable row level security;
alter table public.reminders   enable row level security;
alter table public.feedback    enable row level security;
alter table public.crops       enable row level security;
alter table public.crop_stages enable row level security;
alter table public.diseases    enable row level security;
alter table public.tips        enable row level security;

-- Master data: anyone signed in (incl. anonymous) can read
create policy "read crops"  on public.crops        for select to authenticated using (true);
create policy "read stages" on public.crop_stages   for select to authenticated using (true);
create policy "read dis"    on public.diseases      for select to authenticated using (true);
create policy "read tips"   on public.tips          for select to authenticated using (true);

-- Own-row policies
create policy "own profile"   on public.profiles   for all to authenticated using (id = auth.uid()) with check (id = auth.uid());
create policy "own crops"     on public.user_crops  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "own scans read" on public.scans      for select to authenticated using (user_id = auth.uid());
create policy "own scans ins"  on public.scans      for insert to authenticated with check (user_id = auth.uid());
create policy "own scans upd feedback" on public.scans for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "own saved"     on public.saved_tips  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "own reminders" on public.reminders   for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "own feedback"  on public.feedback    for insert to authenticated with check (user_id = auth.uid());

-- Storage: bucket 'scans' private; user can only touch folder named with their uid
create policy "scans upload own" on storage.objects for insert to authenticated
  with check (bucket_id = 'scans' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "scans read own" on storage.objects for select to authenticated
  using (bucket_id = 'scans' and (storage.foldername(name))[1] = auth.uid()::text);
```
Note: the `diagnose` Edge Function writes scan results using the **service role** key (server-side only) so clients cannot forge diagnoses. In practice make the client only insert the `pending` row; let the function update it. Tighten the `own scans upd` policy to only the `helpful` column via an RPC if you want strictness.

## 3. Mock / seed data
```sql
insert into public.crops (id,name_te,name_en,duration_days,description_te,description_en) values
('rice','వరి','Rice (Paddy)',120,'ఖరీఫ్, రబీ రెండింటిలో సాగు చేసే ప్రధాన పంట.','Main staple crop grown in kharif and rabi.'),
('cotton','పత్తి','Cotton',170,'నల్లరేగడి నేలల్లో బాగా పండుతుంది.','Grows well in black soils.'),
('chilli','మిరప','Chilli',150,'ఆంధ్రప్రదేశ్‌లో ముఖ్యమైన వాణిజ్య పంట.','Important commercial crop in Andhra Pradesh.'),
('groundnut','వేరుశనగ','Groundnut',110,'ఎర్ర నేలల్లో సాగు చేస్తారు.','Grown mostly in red soils.'),
('maize','మొక్కజొన్న','Maize',110,'ఖరీఫ్, రబీ రెండింటిలో సాగు.','Grown in kharif and rabi.'),
('tomato','టమాటా','Tomato',120,'కూరగాయల పంట.','Vegetable crop.'),
('banana','అరటి','Banana',330,'దీర్ఘకాలిక తోట పంట.','Long-duration plantation crop.'),
('sugarcane','చెరకు','Sugarcane',330,'దీర్ఘకాలిక వాణిజ్య పంట.','Long-duration commercial crop.');

-- Rice stages (illustrative)
insert into public.crop_stages (crop_id,stage_order,name_te,name_en,start_day,end_day,care_action_te,care_action_en) values
('rice',1,'నారుమడి','Nursery',0,25,'నారుమడిలో నీరు తగినంత ఉంచండి.','Keep enough water in the nursery.'),
('rice',2,'పిలకలు వేసే దశ','Tillering',26,55,'మొదటి దఫా ఎరువు వేసే సమయం.','Time for the first fertilizer dose.'),
('rice',3,'ఈనిక దశ','Panicle initiation',56,85,'నీరు నిలవ ఉండేలా చూసుకోండి.','Maintain standing water.'),
('rice',4,'గింజ పాలు పోసుకునే దశ','Grain filling',86,110,'తెగుళ్ల కోసం పొలం పరిశీలించండి.','Inspect the field for pests and disease.'),
('rice',5,'కోత','Harvest',111,125,'గింజలు గట్టిపడ్డాక కోత కోయండి.','Harvest when grains are firm.');

-- Diseases: PLACEHOLDER content, expert_verified=false. No chemical names/doses until an expert supplies them.
insert into public.diseases (id,crop_id,name_te,name_en,symptoms_te,symptoms_en,causes_te,causes_en,prevention_te,prevention_en,care_te,care_en,treatment_te,treatment_en,expert_verified,source_note) values
('rice_brown_spot','rice','ఆకుమచ్చ వ్యాధి','Brown spot',
 array['ఆకులపై గోధుమ రంగు మచ్చలు కనిపిస్తాయి.'],array['Brown spots appear on leaves.'],
 array['పోషకాల లోపం, తేమ ఎక్కువగా ఉండటం.'],array['Nutrient deficiency, high humidity.'],
 array['ఆరోగ్యమైన విత్తనం వాడండి.'],array['Use healthy seed.'],
 array['పొలంలో నీరు సరిగా నిర్వహించండి.'],array['Manage field water properly.'],
 array['సరైన మందు, మోతాదు కోసం వ్యవసాయ అధికారిని సంప్రదించండి.'],array['Consult your agriculture officer for the right product and dose.'],
 false,'PLACEHOLDER - replace with ANGRAU/ICAR-verified content'),
('rice_blast','rice','అగ్గి తెగులు','Blast',
 array['ఆకులపై కంటి ఆకారపు మచ్చలు.'],array['Eye-shaped spots on leaves.'],
 array['చల్లని, తేమ వాతావరణం.'],array['Cool, humid weather.'],
 array['ఎక్కువ నత్రజని వేయవద్దు.'],array['Avoid excess nitrogen.'],
 array['పొలాన్ని రోజూ పరిశీలించండి.'],array['Inspect the field daily.'],
 array['సరైన మందు, మోతాదు కోసం వ్యవసాయ అధికారిని సంప్రదించండి.'],array['Consult your agriculture officer for the right product and dose.'],
 false,'PLACEHOLDER'),
('cotton_leaf_curl','cotton','ఆకు ముడత','Leaf curl',
 array['ఆకులు పైకి ముడుచుకుంటాయి.'],array['Leaves curl upward.'],
 array['తెల్లదోమ ద్వారా వ్యాపిస్తుంది.'],array['Spread by whitefly.'],
 array['పొలంలో కలుపు తీసేయండి.'],array['Remove weeds.'],
 array['ప్రభావిత మొక్కలను గమనించండి.'],array['Watch affected plants.'],
 array['సరైన మందు, మోతాదు కోసం వ్యవసాయ అధికారిని సంప్రదించండి.'],array['Consult your agriculture officer for the right product and dose.'],
 false,'PLACEHOLDER'),
('tomato_early_blight','tomato','ఆకు మచ్చ తెగులు','Early blight',
 array['ఆకులపై వలయాకార గోధుమ మచ్చలు.'],array['Concentric brown rings on leaves.'],
 array['తేమ, పాత ఆకులు.'],array['Humidity, older leaves.'],
 array['కింది ఆకులు తీసేయండి.'],array['Remove lower leaves.'],
 array['మొక్కల మధ్య గాలి ఆడేలా చూడండి.'],array['Keep good airflow between plants.'],
 array['సరైన మందు, మోతాదు కోసం వ్యవసాయ అధికారిని సంప్రదించండి.'],array['Consult your agriculture officer for the right product and dose.'],
 false,'PLACEHOLDER');
-- Telugu names/text above are DRAFTS: have a native, farm-literate speaker review.

insert into public.tips (crop_id,category,title_te,title_en,body_te,body_en) values
('rice','crop_care','ఈ రోజు పంట సూచన','Today''s crop-care tip','ఉదయం పొలాన్ని ఒకసారి చుట్టి చూడండి.','Walk your field once in the morning.'),
('rice','fertilizer','దశ ప్రకారం ఎరువు','Fertilizer by stage','పిలకల దశలో ఎరువు సమయం చూసుకోండి.','Check fertilizer timing at tillering.'),
(null,'irrigation_weather','నీరు + వాతావరణం','Irrigation + weather','వర్షం వస్తుందని అంచనా ఉంటే నీరు పెట్టడం ఆపండి.','If rain is forecast, hold irrigation.'),
(null,'pest_prevention','పురుగుల నివారణ','Pest prevention','ఆకుల కింద భాగం చూడండి, పురుగులు ఉంటాయి.','Check the underside of leaves for pests.');
```

## 4. Mock JSON for offline UI development (before Supabase is wired)
```json
{
  "profile": {"id":"demo-user","language":"te","district":"Guntur","latitude":16.31,"longitude":80.44},
  "myCrops": [{"id":"uc1","cropId":"rice","sowingDate":"2026-08-10","fieldSizeAcres":2.5,"locationText":"Guntur"}],
  "scanResultDone": {
    "scanId":"s1","status":"done","cropId":"rice","diseaseId":"rice_brown_spot",
    "confidence":0.92,"imageQuality":"good"
  },
  "scanResultLowConfidence": {"scanId":"s2","status":"low_confidence","confidence":0.41,"imageQuality":"poor"},
  "weather": {"tempC":31,"rainChancePct":60,"humidityPct":78,"windKmh":14,
    "alerts":[{"type":"rain","textTe":"రేపు వర్షం వచ్చే అవకాశం ఉంది. మందు పిచికారీ వాయిదా వేయండి.","textEn":"Rain likely tomorrow. Delay spraying."}]}
}
```
Deck's "92% match" is a prototype example; use it only as mock data.
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
# 06 — Authentication & Route Permissions

## 1. Auth model (guest-first) [ASSUMPTION — deck shows no login screen]
Farmers with limited phone experience should not face a login wall. So:
1. On first launch the app silently calls `supabase.auth.signInAnonymously()` (enable "Anonymous sign-ins" in Supabase Auth settings). A `profiles` row is auto-created by trigger.
2. All features work as a guest. Data is tied to that anonymous user id on that device.
3. Optional upgrade in Profile: **"Sign in with phone (OTP)"** via `updateUser(phone)` / `signInWithOtp(phone)` so data survives a reinstall/new phone. Needs an SMS provider configured in Supabase (paid, e.g., Twilio) — for the prototype, use Supabase **test phone numbers + fixed OTP**, or skip.
4. Sign out returns to a new anonymous session (with a warning that guest data will be lost).

Risk to note: anonymous accounts are easy to abuse -> rate-limit the `diagnose` function per user id and per IP (doc 07).

## 2. Roles
| Role | How obtained | Can do |
|---|---|---|
| `guest` (anonymous) | Auto on first launch | Everything in the app for own data |
| `member` (phone-verified) | OTP upgrade | Same + data persists across devices |
| `service` | Service-role key, Edge Function only | Write scan results, read all |
| `admin/expert` | **Out of prototype scope** | Would verify disease content |

## 3. Route guard rules (go_router `redirect`)
```
if (!appReady)                       -> /splash (init Supabase, prefs, session)
if (!prefs.welcomeSeen)              -> /welcome
if (session == null)                 -> attempt anonymous sign-in; on failure show ErrorRetry
if (path == '/welcome' && welcomeSeen) -> /home
else allow
```
Feature gates (not route redirects):
- Camera/gallery permission denied -> in-screen rationale + "Open settings" button.
- Location permission denied -> district picker fallback.
- No network on `/diagnose` submit -> ErrorRetry ("ఇంటర్నెట్ లేదు"), image kept for retry.

## 4. Route permission matrix
| Route | Guest | Member | Notes |
|---|---|---|---|
| `/welcome` | ✔ (first run) | ✔ | Skipped after first run |
| `/home` | ✔ | ✔ | |
| `/diagnose`, `/diagnose/scan/:id`, `/diagnose/result/:id` | ✔ | ✔ | `:id` must belong to current user (RLS enforces) |
| `/weather` | ✔ | ✔ | Needs location or district |
| `/crops`, `/crops/:id` | ✔ | ✔ | Public master data |
| `/tips` | ✔ | ✔ | |
| `/my-crops`, `/my-crops/new`, `/my-crops/:id/edit` | ✔ | ✔ | Own rows only |
| `/profile`, `/profile/feedback`, `/profile/history` | ✔ | ✔ | |
| `/profile/sign-in-phone` | ✔ | — | Hidden once verified |

## 5. Data-access matrix (enforced by RLS in doc 04)
| Table | select | insert | update | delete |
|---|---|---|---|---|
| profiles | own | trigger | own | — |
| crops, crop_stages, diseases, tips | all authed | — | — | — |
| user_crops | own | own | own | own |
| scans | own | own (pending) | service (result); own (`helpful`) | — |
| saved_tips | own | own | — | own |
| reminders | own | own | own | own |
| feedback | — | own | — | — |
| storage `scans/{uid}/*` | own | own | — | — |

## 6. Secrets & security checklist
- `GEMINI_API_KEY` and the service-role key live **only** in Edge Function secrets — never in the app or repo.
- App ships only `SUPABASE_URL` + `SUPABASE_ANON_KEY` (safe with RLS on).
- Turn RLS **on** for every table before the first pilot user.
- Signed URLs (short expiry) for images; bucket private.
- Limit image size (≤ 3 MB server-side) and content-type (`image/jpeg`,`image/png`).
- Delete-my-data option (Profile) is a P2 but plan for it: images are farm photos linked to a location.
# 07 — API Contracts & Environment Variables

Base: `${SUPABASE_URL}`. All calls carry `Authorization: Bearer <user JWT>` (added by `supabase_flutter`) and `apikey: <anon key>`.

## 1. Edge Function: `POST /functions/v1/diagnose`  (the core API)
**Request**
```json
{
  "scan_id": "uuid",            // row already inserted (status=pending); image already in storage
  "lang": "te",                 // "te" | "en"
  "crop_hint": "rice"           // optional; from My Crops or user pick
}
```
**Success 200 — confident result**
```json
{
  "scan_id": "uuid",
  "status": "done",
  "crop": {"id":"rice","name":"వరి"},
  "disease": {
    "id":"rice_brown_spot","name":"ఆకుమచ్చ వ్యాధి",
    "symptoms":["..."],"causes":["..."],"prevention":["..."],"care":["..."],"treatment":["..."],
    "expert_verified": false
  },
  "confidence": 0.92,
  "image_quality": "good",
  "disclaimer": "ఇది సూచన మాత్రమే..."
}
```
**Success 200 — low confidence / unknown / poor image**
```json
{
  "scan_id":"uuid","status":"low_confidence",
  "crop": {"id":"rice","name":"వరి"} ,     // may be null
  "disease": null,
  "confidence": 0.41,
  "image_quality":"poor",
  "retake_tips":["దగ్గరగా ఒక ఆకును ఫోటో తీయండి.","మంచి వెలుతురులో తీయండి."]
}
```
**Errors** (always `{ "error": { "code": "...", "message": "..." } }`)
| HTTP | code | Meaning | App behaviour |
|---|---|---|---|
| 400 | `bad_request` | missing scan_id/lang | dev bug; generic error |
| 401 | `unauthenticated` | no/invalid JWT | re-init session |
| 403 | `not_your_scan` | scan belongs to another user | generic error |
| 404 | `image_not_found` | file not in storage | retry upload |
| 413 | `image_too_large` | > `MAX_IMAGE_MB` | recompress and retry |
| 429 | `rate_limited` | over per-user limit | "కొంత సేపటి తర్వాత ప్రయత్నించండి" |
| 502 | `ai_unavailable` | Gemini error/timeout | ErrorRetry |
| 504 | `timeout` | > 30s | ErrorRetry |

**Function logic**
1. Verify JWT -> `uid`; load scan; check `scan.user_id == uid`; rate-limit (e.g., 20 scans/user/day, configurable).
2. Download image from `scans` bucket (service role); check size/type.
3. Load closed lists: `select id from crops`, `select id,crop_id from diseases`.
4. Call Gemini with the system prompt in doc 09 (§8) and `responseMimeType: application/json` + schema.
5. Validate: `crop_id` and `disease_id` must be in the lists else treat as `unknown`. Clamp confidence 0–1.
6. If `disease_id == "unknown"` or `confidence < CONFIDENCE_THRESHOLD` or `image_quality == "poor"` -> `status=low_confidence`.
7. Update `scans` row (service role); return payload localized by `lang`.

**Model output schema (Gemini -> function)**
```json
{
  "crop_id": "rice | cotton | chilli | groundnut | maize | tomato | banana | sugarcane | unknown",
  "disease_id": "<id from list> | healthy | unknown",
  "confidence": 0.0,
  "image_quality": "good | poor",
  "visible_symptoms": "short English description"
}
```
(`healthy` -> app shows a friendly "looks healthy" result with prevention tips.)

## 2. Supabase auto-REST / client calls (no custom server)
| Purpose | Call | Notes |
|---|---|---|
| Sign in guest | `auth.signInAnonymously()` | |
| Get/update profile | `from('profiles').select().eq('id',uid)` / `.update({...})` | language, district, lat/lng |
| Crops list | `from('crops').select()` | cache locally |
| Crop stages | `from('crop_stages').select().eq('crop_id',x).order('stage_order')` | |
| Tips | `from('tips').select().eq('category',c)` (optional `crop_id`) | |
| Save tip | `from('saved_tips').insert({tip_id})` / `.delete()` | |
| My crops CRUD | `from('user_crops').select/insert/update/delete` | |
| Create scan | upload to `scans/{uid}/{scanId}.jpg`, then `from('scans').insert({id:scanId,user_id:uid,image_path,language})` | |
| Scan history | `from('scans').select('*, diseases(name_te,name_en), crops(name_te,name_en)').order('created_at',ascending:false)` | |
| Helpful vote | `from('scans').update({helpful:true}).eq('id',id)` | |
| Feedback | `from('feedback').insert({kind,message})` | voice: upload to bucket `feedback` first (P1) |
| Reminders | `from('reminders')` CRUD + schedule local notification | |

## 3. Weather: Open-Meteo (called directly from app)
```
GET https://api.open-meteo.com/v1/forecast
  ?latitude={lat}&longitude={lon}
  &current=temperature_2m,relative_humidity_2m,wind_speed_10m,precipitation
  &daily=precipitation_probability_max,temperature_2m_max,temperature_2m_min
  &timezone=Asia%2FKolkata&forecast_days=3
```
Map to `WeatherSnapshot`. **Alert rules (client-side, prototype):**
- rain chance ≥ 60% tomorrow -> "delay spraying / hold irrigation"
- humidity ≥ 85% -> "fungal disease risk — inspect leaves"
- max temp ≥ 38°C -> "irrigate in early morning/evening"
- wind ≥ 25 km/h -> "avoid spraying today"
(Thresholds are placeholders for an agronomist to set.)
Fallback if no GPS: district -> lat/lng lookup table in `assets/districts.json`.

## 4. Environment variables
**Flutter app** (`env.json`, passed with `--dart-define-from-file`; `env.example.json` committed, `env.json` git-ignored)
| Name | Example | Secret? |
|---|---|---|
| `SUPABASE_URL` | `https://xxxx.supabase.co` | No |
| `SUPABASE_ANON_KEY` | `eyJ...` | No (RLS protects) |
| `OPEN_METEO_BASE_URL` | `https://api.open-meteo.com/v1` | No |
| `DEFAULT_LANGUAGE` | `te` | No |
| `SUPPORT_WHATSAPP_NUMBER` | `+91XXXXXXXXXX` | No (expert button) |
| `FEATURE_FAKE_DIAGNOSE` | `true` | No — use fake responses before Edge Function exists |

**Supabase Edge Function secrets** (`supabase secrets set ...`)
| Name | Example | Secret? |
|---|---|---|
| `GEMINI_API_KEY` | `AIza...` | **Yes** |
| `GEMINI_MODEL` | Flash-class multimodal model name from AI Studio (verify current name) | No |
| `CONFIDENCE_THRESHOLD` | `0.60` | No |
| `MAX_IMAGE_MB` | `3` | No |
| `DAILY_SCAN_LIMIT` | `20` | No |
| `SUPABASE_SERVICE_ROLE_KEY` | (auto-injected in functions) | **Yes** |

**CI/other:** `.gitignore` must include `env.json`, `.env`, `supabase/.env`.

## 5. Fake `diagnose` for early UI work
When `FEATURE_FAKE_DIAGNOSE=true`, `ScanRepo.diagnose()` waits 2.5s and returns the `scanResultDone` mock (doc 04 §4); every 3rd call returns the low-confidence mock so both UIs get tested.
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
