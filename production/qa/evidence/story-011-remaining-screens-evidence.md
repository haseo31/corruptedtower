# Evidence: Story 011 — Remaining screens and player hints

**Story**: `production/epics/pixel-style/story-011-remaining-screens.md`
**Date**: 2026-10-28
**Build**: Godot 4.7.2, 960x640 window (480x320 base view, scaled 2x). Screenshots are the game's own 480x320 frames.
**Method**: scripted runs drove the real game with synthetic keyboard actions only (open evidence, arrows, Enter, Esc), with all six evidence items collected and four verified so the unverified path could be shown; a separate run captured the showdown and the ending. A full keyboard-only playthrough (floor 1, boss 1, floor 2, boss 2, ending, new run) was re-run on the rebuilt evidence screen and ended in the same state at every checkpoint. The scripts are throwaway and not in the repo.

## Screenshots (in `story-011-remaining-screens/`)

| Image | What it shows |
|-------|---------------|
| `01-floor-objective-and-hint.png` | The floor with the objective ("Expose the Deputy Director") and the controls hint in a bordered box at the top right. |
| `02-evidence-screen-first-item.png`, `03-evidence-screen-unverified-item.png` | The evidence menu: an icon beside each name, the arrow on the focused entry, "[?]" on unverified items, and a bordered description box with the item's status ("Unverified. Press Enter to fact-check it."). |
| `04-factcheck-question-and-choices.png` | The fact-check as a question box above a bordered choices menu with the arrow. |
| `05-factcheck-wrong-answer-feedback.png`, `06-factcheck-verified.png` | A wrong answer's feedback, then the verified result: the list entry loses its "[?]", the description box turns to "Verified." and the choices grey out. |
| `07-back-to-list-focus-restored.png` | After Esc, the list gets focus back on the item that was being checked. |
| `08-objective-after-boss.png` | After the boss is exposed the objective reads "Take the stairs up" and the stairs are teal. |
| `09-showdown-menu-with-icons.png` | The showdown's evidence menu with the same icons (four rows shown, scrolling for more). |
| `10-ending-with-cast.png` | The ending in the pixel theme, with the Deputy Director, the player and the Spokesperson on a ground strip, the score and "Start new run". |

## Notes

- The hint and objective text come from each floor's data file (`hint`, `objective`, `objective_boss`, `objective_done`), not from code.
- The icons are drawn by `tools/art/generate_art.py` into `assets/art/icons.png` (deterministic like the other art).
- The arrow marker is centred on one-line rows, including the taller icon rows.

## Sign-off

| Role | Approved | Notes |
|------|----------|-------|
| Developer / lead | [x] Approved | Approved by the user at /story-done on 2026-10-28. |
