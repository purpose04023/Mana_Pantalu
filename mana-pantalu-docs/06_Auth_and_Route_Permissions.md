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
