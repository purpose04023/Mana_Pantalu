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
