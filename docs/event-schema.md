# Event Schema (Primary Task)

All events are written to `bot_events` with common envelope fields:

- `telegram_id` (string)
- `event_name` (string)
- `experiment_name` (string, default: `telegram_onboarding_ab`)
- `variant` (`control` or `test`)
- `event_properties` (json)
- `created_at` (timestamp)

## Required events

1. `experiment_assigned`
- Trigger: first time user is assigned to A/B variant
- Properties:
  - `source`: `statsig`
  - `gate_name`: gate used for assignment

2. `welcome_seen`
- Trigger: control welcome message sent
- Properties:
  - `message_type`: `generic_welcome`

3. `onboarding_step_seen`
- Trigger: each onboarding step message sent to test user
- Properties:
  - `step`: `1 | 2 | 3`

4. `onboarding_completed`
- Trigger: test user reaches final onboarding step
- Properties:
  - `steps_total`: `3`

5. `user_message_received`
- Trigger: every inbound user message
- Properties:
  - `text_length`
  - `has_command` (boolean)

6. `blocked_or_delivery_error` (optional guardrail helper)
- Trigger: telegram send failure handler
- Properties:
  - `error_code`
  - `error_message`
