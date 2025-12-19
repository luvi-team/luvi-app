# AI Code Reviewer – Greptile & CodeRabbit

## 1. Purpose & Scope

This document is the single source of truth for AI-based code review in the LUVI app.

It defines:
- which tools act as merge gates,
- how Greptile and CodeRabbit are used,
- how AI reviews interact with linting, tests and health checks,
- how to interpret and respond to AI review comments.

It applies to **all contributors** using the Codex CLI workflow working on this repository.


## Wie KI dieses Dokument nutzen soll

- Dieses Dokument ist die maßgebliche Richtlinie für Fragen zu AI-Code-Reviews, Merge-Gates, Greptile und CodeRabbit.
- Agents müssen sich an die hier definierten Rollen, Tools und Policies halten; bei Widersprüchen mit anderen Prozessen gewinnt dieses Dokument.
- Nutze den Inhalt ausschließlich für Code-Review-/CI-/Workflow-Themen; Produkt- oder Business-Fragen sind in anderen SSOTs dokumentiert.
- Wenn sich der Workflow ändert (z. B. neue Required Checks), ist zuerst dieses Dokument zu aktualisieren, bevor andere Artefakte angepasst werden.
- Geltungsbereich: Dieses Dokument überschreibt nur AI-Review/CI-Policy; für globale Governance gilt `docs/bmad/global.md`.

---
## 2. Tools & Roles

### 2.1 Greptile (primary AI merge gate)

- **Greptile Review** is the **only AI-related GitHub required check** in branch protection.  
- Every pull request must pass the **"Greptile Review"** status check before it can be merged.  
- Greptile’s job is to review code changes with **full repository context**, focusing on:
  - logic & correctness,
  - security & privacy (Supabase RLS, PII, consent),
  - robustness (error handling, async/await, edge routes),
  - architecture & patterns (Riverpod, GoRouter, Archon/SSOT).
- Greptile runs automatically on PRs via the GitHub App and posts:
  - inline comments,
  - a PR summary (sequence diagram, issues table, confidence score),
  - a GitHub status check `Greptile Review`.

### 2.2 CodeRabbit (local preflight only)

- CodeRabbit is **not** a GitHub required check and **not** part of branch protection.  
- The GitHub App was uninstalled; CodeRabbit runs only **locally** (CLI/IDE) as an optional preflight tool.
- You may use it before pushing a branch to get a quick second opinion on:
  - local refactorings,
  - smaller logic issues,
  - naming / structure suggestions.
- CodeRabbit findings are **never** a formal merge gate. They are personal input for the author.

### 2.3 Classical CI & health checks

In addition to Greptile, these checks remain required merge gates:
- `Flutter CI / analyze-test (pull_request)` – linting & tests
- `Flutter CI / privacy-gate (pull_request)` – privacy / compliance checks
- `Supabase DB Dry-Run` (if enabled) – migration sanity check
- `Vercel Preview Health` – `/api/health` returns 200 in the preview deployment

A PR can only be merged if:
- all CI checks are green, and  
- `Greptile Review` is green.

---
## 3. Greptile configuration & focus

Greptile is configured as follows (summarised – see Greptile dashboard for exact settings):

- **Severity / strictness:** medium  
  → balance between signal and noise; critical issues are always raised.
- **Comment types:** logic, security/privacy, robustness and selected style issues.  
  - Syntax and formatting are primarily enforced by `flutter analyze`, Dart/Flutter lints and formatters.  
  - Greptile should **avoid nitpicking** purely cosmetic issues that are already covered by linters.
- **Custom context:** Greptile has access to:
  - `AGENTS.md` and this document (AI reviewer policy),
  - architecture & product context (App-Kontext, Tech-Stack, Gold-Standard),
  - DSGVO & RLS guidelines.
- **Custom rules (high-level summary):**
  1. **Security – Supabase & RLS**
     - Never use a Supabase `service_role` key or other admin key in client code.
     - Queries to RLS-protected tables must be scoped to the authenticated user and respect RLS policies.
  2. **Privacy & GDPR – PII and consent**
     - Do not log personally identifiable information (email, name, health/cycle data, location).  
     - Use anonymised IDs in logs; respect consent and CMP state for external embeds (e.g. YouTube).
  3. **Robustness – error handling & async/await**
     - Async calls (network, database, edge functions) must handle errors explicitly; no silent failures.
     - Edge/API routes must return structured error responses and should be observable (Langfuse traces for AI-heavy routes).
  4. **Flutter architecture**
     - Use Riverpod for state management and immutable state updates (no direct state mutation).
     - Use GoRouter for navigation instead of raw `Navigator.push/pop` in app feature code.
     - Screens that load data must handle loading and error states (not only the happy path).
  5. **Business logic & SSOT**
     - Business logic around cycle phases, consent state or user ranking should use Archon as single source of truth, not ad-hoc reimplementations.

Greptile reviews should be interpreted in this light: the focus is on **real defects, security/privacy risks and architectural smells**, not on personal preference for micro-style.

### Maintainability & handover readiness

In addition to correctness, security and privacy, Greptile is allowed to flag **maintainability issues** when they clearly harm readability or future changes. Examples include:

- very long or deeply nested widgets/functions that are hard to understand at a glance,
- obvious duplication of non-trivial logic across multiple places,
- classes or functions that mix many responsibilities (e.g. data fetching, transformation and complex UI in one place).

These comments should aim to **make the code easier to understand for future maintainers**, not enforce personal style preferences. Pure micro-style or “could be a one-liner” comments remain optional/nice-to-have.

---
## 4. CodeRabbit usage guidelines (local only)

CodeRabbit may be used locally as an **optional preflight step**:

### 4.1 When to use CodeRabbit

- Before opening a PR for a larger feature or risky change.  
- When you want a quick second opinion on readability and structure.  
- When refactoring legacy code and you want hints for simplification.

Example local flow:

1. Run `flutter format` and `flutter analyze` until clean.  
2. Run relevant tests: `flutter test` (or targeted test commands).  
3. Optionally run CodeRabbit locally (CLI/IDE).  
4. Fix issues that clearly improve correctness, safety or clarity.  
5. Push branch & open PR (Greptile will now review).

### 4.2 What *not* to do with CodeRabbit

- Do **not** treat CodeRabbit findings as hard merge blockers.  
- Do **not** wait for CodeRabbit CI checks on GitHub – there is no CodeRabbit GitHub App anymore.  
- Do **not** blindly accept refactorings that reduce clarity or conflict with project conventions.

---
## 5. Standard workflow with Greptile & CodeRabbit

### 5.1 Local development

1. Implement the change on a feature branch.  
2. Run:
   - `flutter format`  
   - `flutter analyze`  
   - `flutter test` (or relevant test subset)  
3. Optionally run a **local CodeRabbit review** to catch obvious issues before pushing.

### 5.2 Pull request phase

1. Push the branch and open a PR.  
2. Wait for:
   - CI (analyze/test, privacy-gate, DB dry-run, Vercel health)  
   - `Greptile Review` status check  
3. Work through Greptile’s comments:
   - Fix all **blocking** issues (security/privacy, data leaks, RLS, crashes, severe logic bugs).  
   - Consider non-blocking suggestions (refactors, minor cleanups); accept those that improve clarity or maintainability.
4. Once CI and `Greptile Review` are green and you are satisfied, merge the PR.

---
## 6. Interpreting Greptile comments

Use this simple rule of thumb:

- **Must fix before merge:**
  - Security problems (RLS bypass, secrets in code, unsafe auth flows).
  - Privacy violations (PII in logs, missing consent checks).
  - Crashes or clear logic bugs.
  - Broken or missing error handling in critical flows.
- **Strongly recommended:**
  - Architectural issues that clearly hurt maintainability (state leaks, navigation anti-patterns).
- **Optional / nice to have:**
  - Pure style or micro-optimisations that do not affect correctness or clarity.

If in doubt, treat security/privacy issues as **blocking** and document decisions when you intentionally deviate.

---
## 7. Feedback & continuous improvement

Greptile learns from your reactions and comment outcomes.

After each PR:
- Upvote helpful comments (👍) and mark them as resolved when fixed.  
- Downvote false positives (👎) and, if possible, add a short explanation (e.g. “intentional, consent handled in X”).  
- If you see the same false positive pattern multiple times, update the Greptile dashboard:
  - adjust custom rules,
  - narrow scopes or ignore patterns,
  - tweak severity or comment types if needed.

The goal is a reviewer that consistently surfaces **high-value issues** (bugs, risks, architectural smells) with minimal noise.

---
## 8. Dual-Agent Review (Claude Code → Codex)

1. Claude Code erstellt einen PR für UI/Frontend-/Dataviz-Arbeit mit kurzer BMAD-slim-Zusammenfassung, relevanten Checklisten und Testnachweisen.
2. CI läuft wie gewohnt (`Flutter CI / analyze-test`, `Flutter CI / privacy-gate`, `Vercel Preview Health`).
3. `Greptile Review` wird automatisch ausgeführt und muss grün sein.
4. Codex führt ein manuelles Review durch mit Fokus auf:
   - Architektur-Konsistenz (GoRouter, Feature-First-Struktur, SSOT-Verlinkungen),
   - State-Management/Riverpod (saubere Provider-Lifecycles, keine Leaks),
   - DSGVO/Privacy (keine PII-Logs, kein `service_role`, Consent-Flows konsistent),
   - Tests (≥1 Widget-Test für neue Screens/Komponenten, sinnvolle coverage),
   - grundlegende A11y (Kontrast, Semantik, Touch-Targets).
5. Merge erst, wenn **alle** Gates grün sind: CI + Greptile + Codex-Review.

Optional: Falls ein Codex-PR nicht-triviale UI-Anteile enthält, kann Claude Code spiegelbildlich ein UI-Review durchführen (kein required gate, aber empfohlen).

## 9. For Codex CLI (sole agent)

- When working on tasks related to code review, CI, branch protection, or development workflow, **always load this file** as part of your context.  
- Treat this document as the **authoritative policy** for:
  - how Greptile is configured and interpreted,  
  - how CodeRabbit is used locally,  
  - which checks are required before merge.  
- If other documents contradict this one, **this file wins** and the other docs should be updated.
