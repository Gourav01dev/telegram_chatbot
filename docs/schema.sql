create table if not exists public.bot_users (
  id bigserial primary key,
  telegram_id text unique not null,
  username text,
  first_seen_at timestamptz not null default now(),
  experiment_name text not null default 'telegram_onboarding_ab',
  variant text not null check (variant in ('control','test')),
  onboarding_step int not null default 0,
  onboarding_completed boolean not null default false,
  last_active_at timestamptz not null default now()
);

create table if not exists public.bot_events (
  id bigserial primary key,
  telegram_id text not null,
  event_name text not null,
  experiment_name text,
  variant text,
  event_properties jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_bot_events_telegram_id on public.bot_events (telegram_id);
create index if not exists idx_bot_events_created_at on public.bot_events (created_at desc);
create index if not exists idx_bot_events_name on public.bot_events (event_name);
