# Safety Guards (neu)

- Keine destruktiven Commands (DROP, RESET, –hard)
- Undo/Backout nur als Code-Blocks (nicht ausführen)
- UI-Agent: Assets read-only
- Secrets-Deny: .env*, .env.*, .github/secrets*
- Kein Admin-Merge bei rotem CodeRabbit-Status (Override nur mit kurzer Begründung im PR-Template)
- Pre-commit Secret-Hook nicht mit --no-verify umgehen (nur bei verifiziertem False Positive)

