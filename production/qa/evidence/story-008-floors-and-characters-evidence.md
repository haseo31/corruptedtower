# Evidence: Story 008 — Floors and characters

**Story**: `production/epics/pixel-style/story-008-floors-and-characters.md`
**Date**: 2026-10-28
**Build**: Godot 4.7.2, the real game launched windowed at 1152x648 (the camera shows the world at 2x zoom).
**Method**: a scripted run drove the real game with synthetic keyboard actions only (arrows, interact, Enter) and captured each frame; two frames were enlarged for inspection. The script is a throwaway and is not in the repo. The full keyboard-only playthrough (floor 1, boss 1, floor 2, boss 2, ending, new run) was re-run on the restyled build and ended in the same state at every checkpoint.

## Screenshots (in `story-008-floors-and-characters/`)

| Image | What it shows |
|-------|---------------|
| `01-floor1-start.png` | Floor 1 from the atlas: carpet aisle, wood desks, wall blocks and wall faces for the pillar, the Clerk and Janitor sprites, the player on the carpet, a paper icon on a desk (the clue). |
| `02-walk-pose.png`, `14-walk-pose-zoomed.png` | The player mid-step facing right: the walk pose, with crisp pixel edges at 6x. |
| `03-npc-turns-to-face-player.png` | The Clerk has turned to face the player when spoken to. |
| `04-depth-player-north-of-npc.png`, `05-depth-player-south-of-npc.png`, `15-depth-sorting-zoomed.png` | Depth sorting: whoever stands further south draws in front. |
| `06-boss-frame-a.png`, `07-boss-frame-b.png` | The Deputy Director idling between his two frames, beside the red (locked) stairs. |
| `08-desk-with-paper.png`, `09-desk-after-pickup.png` | The clue desk shows the paper tile, then the plain desk tile after pickup. |
| `10-stairs-locked.png`, `11-stairs-open.png` | Red locked stairs, then teal open stairs once the boss is exposed. |
| `12-floor2-start.png`, `13-floor2-intern.png` | Floor 2 with its own cast: Archivist (gray bun, long skirt), Intern (orange spiky hair), the player, and the Spokesperson. |

## Not shown by a still (feel)

- Whether the walk animation, the camera follow and the boss idle feel right in motion.

## Sign-off

| Role | Approved | Notes |
|------|----------|-------|
| Developer / lead | [x] Approved | Approved by the user at /story-done on 2026-10-28; walk animation smoothness and in-motion sharpness deferred to a playtest. |
