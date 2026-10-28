# Story 020 evidence: Filipino version

**Date**: 2026-10-28 | **Type**: UI | **Tester**: self (no independent review)

## What was run

1. **Coverage and loading test** (real game, 12 checks, all PASS): the language switches to Filipino; **0 untranslated sentences** in the evidence, fact-check, dialogue, boss, floor, ending and lessons data (685 table entries in six files); a dialogue, a boss (with its four lies and two-proof lie intact), a fact-check (same answer position), a floor (same map and characters) and the case files load in Filipino; ids are never translated; the language is saved and read back.
2. **Screen test** (real window, injected input): Filipino title, how-to-play pages 1 and 5, Settings, the language switch from Settings (changing it switches at once and rebuilds the title in English), floor 1 title card, the fund clerk's choices, the evidence screen, a showdown, three case-file pages, a closing-guide page and the ending screen.
3. **English regression** (all PASS): the data test for the case files, the choices test (25 checks), the full keyboard playthrough floor 4 to the ending (35 checks, score "18 of 21"), and the choices playthrough.

## Faults found and fixed

- The Settings panel stayed about 1,700 pixels tall in Filipino (a wrapping button measured at zero width). Fixed by giving those buttons a real width, and by making text panels recompute their size when they open.
- Source lines under each case file were still English; they are now translated (titles and names of the sources stay as they are).

## Screenshots (`story-020-filipino/`)

| File | Shows |
|---|---|
| L-title, L-title-english-again | The title in Filipino; after switching back to English |
| L-how-to-play-1, L-how-to-play-5 | The guide |
| L-settings | Settings with the new Wika row |
| L-floor1-title-card, L-clerk, L-clerk-2 | Floor 1 and the fund clerk's choices |
| L-evidence | The evidence screen |
| L-showdown-intro, L-showdown-countered | A showdown in Filipino |
| L-case5-page-1 to 3, L-finale-page-3 | The longest case-file pages and the closing guide |
| L-ending | The ending screen with the notes about the player's choices |

## Notes

- The Filipino text is an AI-written first draft. `design/translation-review-fil.md` says what to check. A native speaker should review it, and the case files should be checked by someone who can verify the facts.
- Sign-off for the UI evidence is the user's, on story-done.
