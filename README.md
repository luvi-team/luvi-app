# LUVI

**Women-first Daily Health Companion**

Health · Lifestyle · Longevity — know what's good for you in 30 seconds, every day.

Built with Flutter + Supabase · EU-hosted · GDPR-compliant

---

## What is LUVI?

LUVI helps women (primarily in their 20s–50s, open to all adults) better understand their body, hormones, and future self — with curated, evidence-based content and programs aligned to their cycle and daily life.

**The problems we solve:**

- Too much contradictory health content online
- No training plans aligned with the menstrual cycle
- No single place to both act AND understand

**LUVI is:**

- 🌙 **Lifestyle-first, cycle-aware** — Recommendations tailored to your phase, but not a medical product
- 📚 **Curated & evidence-based** — Human + AI curation, no hype-hacks or crash diets
- 🏋️ **Act + Understand** — Workouts, programs, and explanations in one place
- 🇪🇺 **EU-hosted, Consent-first** — All infrastructure in EU, explicit consent for everything

---

## Content Pillars

| Pillar | Focus |
|--------|-------|
| **Training & Movement** | Workouts (bodyweight, yoga, mobility, cardio) |
| **Nutrition & Biohacking** | Everyday tips, evidence-based, no extreme diets |
| **Sleep & Recovery + Mind** | Sleep hygiene, breathing exercises, stress coping |
| **Beauty, Skin & Bodycare** | Skincare basics, realistic context |
| **Longevity & Future Self** | Blood sugar, muscle mass, "What actually works?" |
| **Cycle & Hormones** | Across all pillars — phase tags, no diagnoses |

---

## Free vs Premium

**Free (Stream & Daily Companion):**

- Daily feed with "Today with LUVI" suggestions
- Endless stream with filters (pillar, duration, language)
- Save, playlists, share

**Premium (Coach & Deep Dives):** *(some features in development)*

- Structured 4–8 week programs (e.g., "Cycle-Smart Strength")
- AI search & AI playlists *(planned)*
- Exclusive deep-dive series

---

## Status

🚧 **In development** — iOS-first MVP in progress.

---

## Getting Started

### Prerequisites

- Flutter 3.38+
- Supabase account (EU region required)

### Quick Start

    git clone https://github.com/luvi-team/luvi-app.git
    cd luvi-app
    flutter pub get
    cp .env.example .env.development
    # Add your Supabase URL and anon key to .env.development
    ./scripts/run_dev.sh

See [docs/engineering/](docs/engineering/) for detailed setup and workflows.

---

## Project Structure

    lib/
    ├── core/          # Design tokens, theme, navigation, analytics
    ├── features/      # Feature modules (auth, consent, cycle, dashboard)
    └── l10n/          # Localization (DE/EN)
    services/          # Shared Dart package
    test/              # Mirrors lib/ structure
    docs/              # Engineering, product, privacy docs

---

## Contributing

Before submitting a PR, please review:

- [Engineering Docs](docs/engineering/) — Setup, workflows, quality gates
- [Product Context](docs/product/) — Roadmap and app context

---

## Security

Report vulnerabilities via [GitHub Security Advisories](../../security/advisories/new).

**Hard rules:** No secrets in repo. No `service_role` in client code.

---

## License

Proprietary — All rights reserved until further notice.
