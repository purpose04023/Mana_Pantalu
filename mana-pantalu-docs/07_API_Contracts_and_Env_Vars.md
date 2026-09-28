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
