# Onboarding Option IDs (SSOT)

Ziel: Persistente Werte in Supabase müssen **stabile interne IDs** sein (keine UI‑Labels), damit Copy/Order‑Änderungen keine “Meaning Drift” verursachen.

SSOT‑Quelle (Code): `lib/features/onboarding/model/onboarding_option_ids.dart`.

## `public.profiles.fitness_level` (text)
- `beginner`
- `occasional`
- `fit`

## `public.profiles.goals` (jsonb array of string)
- `fitter`
- `energy`
- `sleep`
- `cycle`
- `longevity`
- `wellbeing`

## `public.profiles.interests` (jsonb array of string)
- `strength_training`
- `cardio`
- `mobility`
- `nutrition`
- `mindfulness`
- `hormones_cycle`

