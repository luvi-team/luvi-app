# Privacy Review — 20250916191813_fix_search_path_functions

## Change
Pin `search_path` for trigger helpers:
- `public.set_user_id_from_auth()`
- `public.update_updated_at_column()`

## Data Impact
- **No new tables/columns**
- **No data reads/writes added**
- **No PII exposure**; function bodies unchanged

## Purpose / Risk
- Hardening: avoid path hijacking in function resolution
- Risk: none to user privacy; behavior unchanged

## RLS / Access Control
- Owner-based RLS remains active; no policy change

## DPIA/DSGVO
- No change to processing scope or data categories
- No transfer/processor changes

## Result
- ✅ Privacy-neutral migration; no further action required