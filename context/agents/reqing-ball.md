# Agent: reqing-ball

## Goal
Validate PR diffs against story/PRD and relevant ADRs; identify gaps and next actions.

## Inputs
PR diff (only diff, no full codebase), story/PRD criteria, ADR snippets.

## Output
Table (Finding_ID | Criterion | Finding | File:Line | Severity | Action) as PR comment.

## Rules
No full scans, GDPR-safe (no PII in outputs, no persistent storage of personal data), short and concise.

### GDPR Personal Data Definition

For this agent, **personal data** (Art. 4(1) GDPR) includes:
- GitHub usernames (`@username`)
- Email addresses
- User IDs (UUID or numeric)
- IP addresses

**NOT personal data in this context:**
- Finding IDs (`REQ-123-01`) - synthetic identifiers
- File paths and line numbers
- Code snippets (unless containing hardcoded credentials)
- PR numbers and branch names

### Data Handling & Retention

| Data Type | In Outputs | Storage Location | Retention Period |
|-----------|-----------|------------------|------------------|
| GitHub usernames | Allowed (public) | PR comments | GitHub default (indefinite until PR deleted) |
| Email addresses | **NEVER** | None | N/A |
| Finding IDs | Allowed | PR comments + labels | GitHub default |
| Adjudication logs | Username + action | PR comments | GitHub default |

**Retention Policy:** All agent outputs follow GitHub's data retention policy. PR comments persist indefinitely unless manually deleted or repository is removed. No external storage or backup of personal data.

**Access Controls:** Agent outputs visible only to repository collaborators (GitHub permissions). No external logging beyond GitHub.

*Consult Privacy/Legal team for jurisdiction-specific retention requirements.*

## Acceptance Criterion
- **Output Length:** ≤ 30 lines per PR comment. **Action on Violation:** Self-truncate to 30 lines and append a note: "*(Truncated for brevity)*".
- **False Positive Definition:** An alert flagged by the agent that, after human review by the PR author or designated reviewer, is determined to be incorrect (i.e., the flagged issue does not actually violate the criterion).
- **Measurement:** Count of adjudicated false-positive alerts divided by number of PRs reviewed. **Adjudication:** Decided by PR author/reviewer consensus and recorded by applying the label `adjudicated-fp` to the PR and adding a comment with format: `[FP-Adjudication] Finding: {Finding_ID}, Decision: False Positive, By: @user`.
- **True Positive Recording:** When a finding is confirmed valid (true positive), record with comment: `[TP-Adjudication] Finding: {Finding_ID}, Decision: True Positive, By: @user`. Apply `adjudicated-tp` label (distinct from FP label for filtering).
- **Calibration Phase:** First 20 PRs or 4 weeks (whichever comes first).
- **Threshold:** ≤ 0.5 false positive per PR during calibration; post-calibration target ≤ 0.2 per PR.
  - **Calculation:** FP count / PR count over a sliding window of the 10 most recent PRs.
  - **Example:** 3 FPs in 10 PRs = 0.3 FP/PR (exceeds 0.2 threshold).
- **Enforcement:** Triggered when the 10-PR rolling average exceeds 0.2 for **3 consecutive PR reviews** (PR N, N+1, AND N+2). Upon trigger: Agent rules must be reviewed before further automated reviews.

## Adjudication Automation

### Bot Command (MVP)
Use `/adjudicate` command in PR comments:

| Command | Action |
|---------|--------|
| `/adjudicate FP {Finding_ID}` | Applies `adjudicated-fp` label + comment template |
| `/adjudicate TP {Finding_ID}` | Applies `adjudicated-tp` label + comment template |

### Authorization & Permissions

**Who can run `/adjudicate`:**
- PR author (creator of the pull request)
- Repository maintainers with write access (GitHub "Maintain" or "Admin" role)
- Designated reviewers explicitly assigned to the PR

**Enforcement**:
- GitHub bot validates requester via GitHub API before applying labels
- Permission check: `GET /repos/{owner}/{repo}/collaborators/{username}/permission`
- Required level: `write`, `maintain`, or `admin`
- If unauthorized: Bot responds with error, no labels applied, audit logged

**Validation Rules**:
- Finding_ID format: `REQ-{PR#}-{SEQ}` (e.g., `REQ-123-01`)
- Finding_ID must exist in current PR's reqing-ball review comment
- Invalid format → Bot rejects with error message
- Duplicate adjudication → Bot warns but updates label (allows correction)

**Audit Trail**:
- All commands logged with timestamp, user, Finding_ID, decision
- Log format: GitHub comment + optional external audit log
- Failed permission checks logged separately for security monitoring

**Rate Limiting**:
- Max 30 adjudications per user per PR *(aligned with 30-line output limit)*
- Cooldown: 1 second between commands *(balances responsiveness with abuse prevention)*
- Exceeding limits → Bot responds with rate limit message

**Limits Reference:**
| Limit | Value | Scope | Purpose |
|-------|-------|-------|---------|
| Output | 30 lines | Per PR comment | Agent review brevity |
| Adjudications | 30 | Per user per PR | Matches output limit |
| Cooldown | 1 sec | Between commands | Rate limiting |

*Note: These defaults balance usability with spam prevention. Values are configurable via bot environment variables when deployed. Adjust for different deployment contexts as needed.*

**Implementation Status**: Bot command planned for MVP. Manual workflow operational for interim use.

### Comment Template (Auto-Generated)
```
[{TP|FP}-Adjudication] Finding: {Finding_ID}, Decision: {True|False} Positive, By: @user
```

### Manual Fallback
If bot unavailable:
1. Add comment using the template from "Comment Template (Auto-Generated)" section above:
   `[{TP|FP}-Adjudication] Finding: {Finding_ID}, Decision: {True|False} Positive, By: @user`
2. Apply the appropriate label: `adjudicated-fp` (false positive) or `adjudicated-tp` (true positive)

## Operative Mode
Codex CLI-first (BMAD → PRP).

**Definitions:**
- **Codex CLI-first:** Backend/DB tasks are prioritized via Codex agent.
- **BMAD:** Business Model & Architecture Doc.
- **PRP:** Project Roadmap & Plan.
- **RLS:** Row-Level Security (Postgres policy-based access control).
- **BMAD-Slim flow:** See `docs/bmad/claude-code-slim.md`.
- **Acceptance gates:** See `context/agents/_acceptance_v1.1.md`.

## When to Use (LUVI-specific)
- Use before larger backend or cross-feature tasks to refine requirements/PRD/ADRs (e.g., new dashboard module, additional consent step).
- Required for high-impact topics (DB schema, privacy/RLS) before starting implementation.
- Not needed for micro-tasks like copy/spacing fixes; direct BMAD-Slim flow with `_acceptance_v1.1.md` is sufficient.
