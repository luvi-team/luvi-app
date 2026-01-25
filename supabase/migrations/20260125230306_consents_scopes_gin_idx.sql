-- Add GIN index on consents.scopes to speed up scope existence checks (e.g. scopes ? 'analytics').

begin;

create index if not exists idx_consents_scopes_gin
  on public.consents
  using gin (scopes);

commit;
