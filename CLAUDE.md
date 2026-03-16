# CLAUDE.md

## gstack

Use the `/browse` skill from gstack for all web browsing. Never use `mcp__claude-in-chrome__*` tools.

### Available skills

- `/plan-ceo-review` - CEO-level plan review
- `/plan-eng-review` - Engineering plan review
- `/review` - Code review
- `/ship` - Ship code
- `/browse` - Web browsing
- `/qa` - QA testing
- `/setup-browser-cookies` - Set up browser cookies
- `/retro` - Retrospective

# Globale Entwickler-Präferenzen

## Allgemeine Regeln
- Bevorzuge TypeScript über JavaScript
- Schreibe Code auf Englisch, Kommentare auf Deutsch
- Verwende moderne ES6+ Syntax
- Keine console.log() in Production-Code

## Code-Qualität
- Schreibe sauberen, lesbaren Code
- Verwende aussagekräftige Variablennamen
- Halte Funktionen klein (max. 20 Zeilen)
- DRY-Prinzip befolgen

## Fehlerbehandlung
- Immer try-catch bei async/await
- Niemals Fehler verschlucken
- Aussagekräftige Fehlermeldungen

## Git
- Commit-Messages auf Deutsch
- Conventional Commits Format nutzen
- Niemals direkt auf main pushen

## Testen
- Teste immer wenn möglich

## Github
- erstelle einen Pull Request pro Phase
