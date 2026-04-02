# Evaluation Plan (Primary Task)

## Experiment
- Name: `telegram_onboarding_ab`
- Population: new Telegram users only
- Randomization unit: `telegram_id`
- Provider: Statsig gate assignment

## Primary metric (leading indicator)
- **Activated User Rate (AUR-24h)**
- Definition: `% of newly assigned users who send >=2 meaningful messages within first 24h after assignment`
- Why this metric: strong early engagement proxy and practical leading indicator for long-term retention in chat products

## Guardrail metrics
1. **Bot block rate (24h/7d)**
- `% users who block bot (or become unreachable) after first interaction`

2. **Delivery error rate**
- `% outbound sends failing with Telegram error`

3. **Complaint proxy rate**
- `% users sending negative intent keywords (e.g. stop, spam)`

## Secondary metrics
1. Day-1 return rate
2. Day-7 return rate
3. Onboarding completion rate (test group only)
4. Median time-to-first-reply

## Pre-committed decision framework
- Minimum runtime: 14 days
- Minimum sample: 400 users/variant (or first date when both pass this threshold)
- Success criteria:
  1. AUR-24h in Test >= Control by +5 percentage points (absolute uplift), and
  2. No guardrail breach
- Guardrail breach conditions:
  - Block rate increase > +2 percentage points absolute, or
  - Delivery error rate increase > +1 percentage point absolute
- Actions:
  - If success criteria met and no breach: roll out guided onboarding to 100%
  - If uplift positive but guardrail breached: iterate onboarding copy/step timing, rerun test
  - If no uplift: keep control and redesign hypothesis

## Analysis notes
- Analyze intention-to-treat by assigned variant
- Report confidence intervals for uplift
- Segment readout by acquisition day and first-message locale (if available)
