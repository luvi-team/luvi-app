# Onboarding Option IDs (SSOT)

Goal: Persisted values in Supabase must use **stable internal IDs** (not UI labels) to prevent "meaning drift" when copy/order changes.

SSOT Source (Code): `lib/features/onboarding/model/onboarding_option_ids.dart`.

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
