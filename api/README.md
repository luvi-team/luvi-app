# LUVI Vercel Functions

This directory contains the Node.js/TypeScript backend for LUVI's Vercel Functions. The hybrid architecture keeps Supabase focused on Auth/CRUD/Realtime (with RLS enforced) while Vercel handles AI endpoints, webhooks, and aggregation-heavy workloads. For the complete technology stack, see `docs/engineering/tech-stack.md`. Every request is expected to carry a Supabase-issued JWT, all logging must go through the PII-safe logger, and the current CORS setup stays permissive for the Flutter client until origin pinning is introduced in later phases. Health ist bewusst offen (Smoke-Test). Produktive Routen nutzen die Allow-List aus `ALLOWED_ORIGINS`.

## Directory Structure

```
/api
├── health.ts              # Health check endpoint (GET /api/health, absichtlich ohne Login – reine Funktionsprobe)
├── utils/
│   └── logger.ts          # Structured logger (no PII)
├── __tests__/             # Unit tests (Jest)
│   ├── health.test.ts
│   └── utils/
│       └── logger.test.ts
├── package.json           # Node.js dependencies
├── tsconfig.json          # TypeScript config
├── jest.config.js         # Jest config
├── .eslintrc.json         # ESLint rules
├── .prettierrc.json       # Prettier formatting
└── README.md              # This file
```

## Development Workflow

- Install dependencies: `cd api && npm install`
- Run unit tests: `npm test` (watch mode: `npm run test:watch`)
- Generate coverage: `npm run test:coverage`
- Type-check: `npm run typecheck`
- Lint: `npm run lint`
- Format: `npm run format`
- Local execution: `vercel dev` (see `docs/runbooks/test-edge-function-locally.md` for patterns and adapt to Vercel Functions)

## Testing Guidelines

- Every endpoint must ship with Jest unit tests and ≥80 % coverage, matching the expectations in `docs/product/roadmap.md`.
- Use `api/__tests__/` as the convention for grouping endpoint and utility tests.
- Logger tests are mandatory—PII redaction is a compliance requirement, not optional.

## DSGVO Compliance

- Always use `api/utils/logger.ts` for structured logging.
- Allowed fields in logs: `request_id`, `timestamp`, `level`, `error_type`, `status_code`, `endpoint`, `method`.
- Erlaubte nicht-personenbezogene Meta-Felder: `request_id`, `endpoint`, `method`, `status_code`, `timestamp`, `level`. Keine PII (automatisch geschwärzt).
- Forbidden fields in logs (automatically redacted): `user_id`, `email`, `name`, `phone`, `address`, `ip_address`, `cycle_phase`, `lmp_date`, `period_length`, `symptoms`, and related health data.
- Refer to `docs/privacy/dsgvo-impact-levels.md` for the official impact assessment and guardrails.

## Deployment

- Pushing to `main` triggers Vercel to deploy everything under `/api` automatically.
- Secrets and API keys are configured in the Vercel dashboard—never commit them to the repository.
- A dedicated runbook (`docs/runbooks/deploy-vercel.md`) will be added in a later phase for end-to-end deployment steps.

## Next Steps (M5 Roadmap)

1. Phase 3: AI-Gateway middleware (rate limiting, circuit breaking, centralised error handler).
2. Phase 4: Upstash Redis integration for caching and the shared PII-redaction utility.
3. Phase 5: Flutter API client that consumes these endpoints.

See `docs/product/roadmap.md` and ADR-0003 (`context/ADR/0003-dev-tactics-miwf.md`) for guidance on the “happy path first” approach that drives these phases.
