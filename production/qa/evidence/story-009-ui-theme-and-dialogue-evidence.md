# Evidence: Story 009 — UI theme, view size and dialogue box

**Story**: `production/epics/pixel-style/story-009-ui-theme-and-dialogue.md`
**Date**: 2026-10-28
**Build**: Godot 4.7.2, the real game launched in a 960x640 window (the base view is 480x320, scaled 2x by whole numbers only). Screenshots are the game's own 480x320 frames.
**Method**: scripted runs drove the real game with synthetic keyboard actions only. The dialogue frames were captured at the normal typing speed (45 characters per second); the rest of the screens came from a full keyboard-only playthrough with the typing set to instant. The scripts are throwaway and are not in the repo. The playthrough (floor 1, boss 1, floor 2, boss 2, ending, new run) ended in the same state at every checkpoint.

## Screenshots (in `story-009-ui-theme-and-dialogue/`)

| Image | What it shows |
|-------|---------------|
| `01-floor-view-480x320.png` | The floor in the 480x320 view, with the floor name in a bordered box. |
| `02-dialogue-typing.png` | The dialogue box mid-line: "You are not on" typed so far, speaker name in blue above. |
| `03-dialogue-line-complete-arrow-on.png`, `03b-...-arrow-off.png` | The line complete with the continue arrow in both phases of its blink. |
| `04-interact-skips-to-full-line.png` | Interact pressed while typing shows the whole line at once. |
| `05-choices-menu.png`, `06-choices-arrow-moves.png` | The choices menu in a bordered box above the text box; the arrow marks the selected entry and moves with the Down key. |
| `07-evidence-notice.png` | The green "+ Evidence" notice in the text box. |
| `flow-01-factcheck-verified.png`, `flow-02-evidence-all-verified.png` | The evidence list (inverted selection) beside the fact-check panel, before and after verifying. |
| `flow-03-locked-stairs-message.png` | The locked-stairs notice in the dialogue box. |
| `flow-04-showdown-open.png`, `flow-05-...-wrong-meter-rises.png`, `flow-06-showdown-won.png` | The showdown screen with the arrow-marked evidence menu. |
| `flow-07-floor-2-showdown.png`, `flow-08-floor-2-won.png` | The floor 2 showdown. |
| `flow-09-ending-screen.png` | The ending screen in the pixel theme. |
| `flow-10-new-run-floor-1.png` | A new run back on floor 1. |
| `flow-11-showdown-lost-try-again.png`, `flow-12-showdown-restarted.png` | The lose and Try again states. |

## Notes

- The evidence list marks the selection by inverting it (dark bar, light text), not with the arrow; the arrow marker for that list comes with story 011.
- The showdown screen only fits the new view here; its battle-style layout is story 010.
- A wrapping menu button collapsed to zero width when set to shrink; the ending button is set to fill instead.

## Sign-off

| Role | Approved | Notes |
|------|----------|-------|
| Developer / lead | [x] Approved | Approved by the user at /story-done on 2026-10-28. |
