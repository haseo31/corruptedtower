# Evidence: Story 010 — Battle-style showdown

**Story**: `production/epics/pixel-style/story-010-battle-showdown.md`
**Date**: 2026-10-28
**Build**: Godot 4.7.2, 960x640 window (480x320 base view, scaled 2x). Screenshots are the game's own 480x320 frames.
**Method**: (1) a standalone script put the real `ShowdownScreen` on screen with a six-item inventory and drove it with synthetic keyboard actions at real speed (effects on); (2) a full keyboard-only playthrough of the real game (floor 1, boss 1, floor 2, boss 2, ending, new run) was re-run on the new screen and ended in the same state at every checkpoint. Both scripts are throwaway and not in the repo.

## Screenshots (in `story-010-battle-showdown/`)

| Image | What it shows |
|-------|---------------|
| `01-open.png` | The battle layout: boss on a platform (upper right, 2x, its own sprite), player back view (lower left, 2x), the boss panel with name and an empty Cover-up bar, the text box with the hint and the first lie, the evidence menu with the arrow on the first item. |
| `02-boss-flash-on-counter.png` | The boss flashes bright for an instant when a lie is countered. |
| `03-after-counter-next-lie.png` | After the counter: "That exposes the lie." and the next lie. |
| `04-menu-scrolled-selection-visible.png` | The menu has scrolled to keep the sixth item selected, showing exactly five whole rows. |
| `05-shake-on-wrong.png`, `06-wrong-feedback-bar-1.png` | A wrong answer: the screen is shaken a few pixels, the Cover-up bar fills one third, and the feedback replaces the text. |
| `07-lost-try-again.png`, `08-restarted.png` | The lose state (full bar, "Try again") and the restarted showdown (bar empty, evidence menu back). |
| `09-won-continue.png` | The win state with "Continue". |
| `game-04` to `game-08` | The same screen inside the real game: floor 1 open, a wrong turn, the win, then the floor 2 showdown against the Spokesperson. |

## Notes

- A regression run caught a real bug while this story was being built: with the menu showing exactly five rows, the sixth item was fully scrolled out of view and Godot's arrow-key navigation skipped it, so a keyboard player could not reach it. The menu entries are now linked to each other by hand.
- Effects (flash, shake) are short, never block input, and can be turned off with the static `ShowdownScreen.reduce_motion`.

## Sign-off

| Role | Approved | Notes |
|------|----------|-------|
| Developer / lead | [x] Approved | Approved by the user at /story-done on 2026-10-28. |
