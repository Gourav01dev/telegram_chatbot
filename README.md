# CalorAI Test Task

This repository contains the implementation for the **Primary Task**:

- Telegram chatbot in `n8n`
- A/B group assignment using `Statsig`
- Event logging to `Supabase`
- Evaluation plan documentation

## Live Bot (for demo)

- Bot username: `@Calorai_april2_test_bot`
- Bot link: `https://t.me/Calorai_april2_test_bot`

If token/username changes, update this section before submission.

## Repository Structure

- `n8n/primary-ab-test-workflow.json`
  - Importable n8n workflow for primary task
- `docs/schema.sql`
  - SQL schema for `bot_users` and `bot_events`
- `docs/event-schema.md`
  - Event contracts and payload fields
- `docs/evaluation-plan.md`
  - Hypothesis, primary metric, guardrails, secondary metrics, decision framework
- `.env.example`
  - Variable names used in local/self-hosted setup

## What This Workflow Does

1. Receives user messages from Telegram.
2. Normalizes user payload (`telegram_id`, username, text, metadata).
3. Logs inbound event (`user_message_received`) to Supabase.
4. Checks if user already exists in `bot_users`.
5. If new user:
- requests assignment from Statsig (`telegram_onboarding_ab` gate)
- stores assignment in `bot_users`
- logs `experiment_assigned`
6. Routes by variant:
- `control`: sends generic welcome message
- `test`: sends guided 3-step onboarding (state persisted in DB)
7. Logs downstream events (`welcome_seen`, onboarding events).

## Architecture Overview

- **Orchestration**: n8n Cloud workflow
- **Experiment assignment**: Statsig HTTP API (`/v1/check_gate`)
- **Storage + analytics sink**: Supabase Postgres (`bot_users`, `bot_events`)
- **Delivery channel**: Telegram Bot API

## Prerequisites

- Telegram account + `@BotFather`
- n8n account (cloud used in this project)
- Supabase project
- Statsig project

## Setup Instructions

### 1. Supabase Setup

1. Create a Supabase project.
2. Open SQL Editor and run [`docs/schema.sql`](docs/schema.sql).
3. Open `Settings -> API Keys` and copy:
- Project URL
- `service_role` key

Use these in HTTP nodes:
- `SUPABASE_URL = https://<project-id>.supabase.co`
- `SUPABASE_SERVICE_ROLE_KEY = <service_role_jwt>`

### 2. Statsig Setup

1. Create a Statsig project.
2. Go to `Settings -> API Keys` and copy **Server Secret Key** (`secret-...`).
3. Create experiment/gate named: `telegram_onboarding_ab`.
4. Ensure split supports Control/Test (50/50 for test task demo).

### 3. Telegram Bot Setup

1. Open `@BotFather` in Telegram.
2. Run `/newbot` and create a bot.
3. Copy token (`123456:AA...`).
4. In n8n, create Telegram credentials with this token.

### 4. Import Workflow in n8n

1. Open n8n.
2. Import: `n8n/primary-ab-test-workflow.json`.
3. Attach Telegram credential to:
- `Telegram Trigger`
- `Send Control Welcome`
- `Send Test Message`

### 5. Important n8n Cloud Note (Very Important)

n8n Cloud can block `$env.*` usage in nodes (`access to env vars denied`).

If this happens:
- Use **Fixed** values in HTTP nodes (URL + headers), not `$env.*` expressions.
- Keep only item expressions like `$json.telegram_id` where required.

Required fixed headers for Supabase HTTP nodes:
- `apikey: <service_role_key>`
- `Authorization: Bearer <service_role_key>`
- `Content-Type: application/json`

Required fixed headers for Statsig node:
- `STATSIG-API-KEY: <server_secret_key>`
- `Content-Type: application/json`

### 6. Publish Workflow

- Click `Publish` / activate workflow in n8n.
- After publishing, manual `Execute workflow` is not required for every message.

## Verification Checklist (Primary Task)

### Telegram verification

1. Send `/start` to bot.
2. Confirm bot replies with either:
- Control welcome message, or
- Test onboarding step message.

### Supabase verification

Check `bot_users`:
- New user row exists
- `variant` is set (`control` or `test`)

Check `bot_events`:
- `user_message_received`
- `experiment_assigned`
- `welcome_seen` (control) or onboarding events (test)

### Branch verification

- Validate at least one control run and one test run.
- If same user is always in same variant, test with a new Telegram account (expected behavior).

## Troubleshooting

### 1) `access to env vars denied`

Cause:
- Node has `$env.*` expression in n8n Cloud.

Fix:
- Replace `$env.*` with fixed URL/header values in that node.

### 2) `duplicate key value violates unique constraint bot_users_telegram_id_key`

Cause:
- Existing user re-insert attempt.

Fix options:
- Ensure new/existing branching is correct, and/or
- Use upsert style in Insert URL:
  - `.../bot_users?on_conflict=telegram_id`
  - Header `Prefer: resolution=merge-duplicates,return=representation`

### 3) `Bad Request: chat_id is empty`

Cause:
- `telegram_id` not present in node input.

Fix:
- In message nodes, use safe chat id expression:
  - `{{$json.telegram_id || $('Normalize Incoming').first().json.telegram_id}}`

### 4) Message not arriving in Telegram

Checklist:
- Workflow is published/active
- Correct bot token in credential
- Correct bot chat (`@Calorai_april2_test_bot`)
- Re-test with `/start`

## Evaluation Framework

See full plan in [`docs/evaluation-plan.md`](docs/evaluation-plan.md).

- Primary metric: Activated User Rate (AUR-24h)
- Guardrails: block rate, delivery error rate, negative intent proxy
- Secondary metrics: D1/D7 return, onboarding completion, time-to-first-reply
- Pre-committed decisions with thresholds included in doc

## Event Schema

See [`docs/event-schema.md`](docs/event-schema.md) for event names and payload fields.

## Assumptions and Trade-offs

- Used Supabase as lightweight storage + analytics sink.
- Used direct HTTP nodes for simplicity and speed.
- n8n Cloud env restrictions required fixed-value configuration in nodes.
- Focused on reliability and clarity for interview evaluation.

## Security Notes

- Never commit real secrets/tokens to git.
- If any token/key is exposed:
1. Revoke/rotate Telegram bot token via BotFather
2. Rotate Statsig server secret
3. Rotate Supabase service role/JWT secret if needed

## Time Tracking (fill before final submission)

- Primary Task: `__ min`
- Secondary Task: `__ min`
- Bonus Task 1: `__ min`
- Bonus Task 2: `__ min`
- Bonus Task 3: `__ min`

## Submission Checklist

- Primary task workflow functional
- Event logging validated in Supabase
- Evaluation plan documented
- README complete and accurate
- Code pushed to public GitHub repo
- Walkthrough video (5-10 min) recorded

