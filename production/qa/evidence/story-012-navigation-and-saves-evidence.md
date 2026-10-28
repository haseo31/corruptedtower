# Evidence: Story 012 — Floor navigation and save/load

**Story**: `production/epics/longer-game/story-012-navigation-and-saves.md`
**Date**: 2026-10-28
**Build**: Godot 4.7.2, 960x640 window (480x320 base view, scaled 2x). Both runs used a scratch save file (`user://test_save.json`), so the player's real save was never touched; no save file was left behind.
**Method**: (1) a headless scenario of the save rules (22 checks, all passed); (2) a keyboard-only run of the real game; (3) the full keyboard-only playthrough re-run (floor 1, boss 1, floor 2, boss 2, ending, new run), which ended in the same state at every checkpoint. The scripts are throwaway and not in the repo.

## Playtest record: the key scenario (keyboard only)

1. Esc on a fresh floor: the pause menu opens with Load greyed out and "There is no saved game yet."
2. With floor 1 beaten (3 evidence items verified, boss defeated) and the player beside the stairs, Esc, Down, Enter saves: "Game saved."
3. The progress was wiped and a fresh run started on floor 2 (0 items, boss not defeated).
4. Esc, Down, Down, Enter on Load: the game printed `scene=Floor1 cell=(37, 12) items=3 verified=3 boss defeated=true`: floor 1, the saved tile, all evidence with its verified flags, the boss defeated, and the stairs open (`05`).
5. With the save file damaged, Load shows "That save could not be read." and the game stays on the same floor.
6. With the save deleted, the menu greys out Load again.

## Screenshots (in `story-012-navigation-and-saves/`)

| Image | What it shows |
|-------|---------------|
| `01-pause-menu-no-save-load-greyed.png` | The pause menu with no save: Load greyed, the message. |
| `02-saved-message.png` | "Game saved." after Save. |
| `03-wiped-state-on-floor-2.png`, `04-pause-menu-load-now-enabled.png` | The wiped run on floor 2, and the menu with Load available. |
| `05-loaded-floor-1-stairs-unlocked.png` | After Load: floor 1 at the saved tile, teal (open) stairs, objective "Take the stairs up". |
| `06-damaged-save-message.png`, `07-no-save-message-again.png` | The damaged-save message and the no-save message. |

## Save-rules scenario (22 checks, all passing)

No save at first and a clear message; save is versioned (version 1); floor, tile, evidence with verified flags and defeated bosses round-trip; restoring a wiped session brings everything back exactly; a damaged file, a JSON list, another version, an unknown floor, unknown evidence, a bad position and a missing field are each refused with a message; every staircase has a matching one beside its arrival cell; the first floor has only stairs up (locked until its boss) and the last only stairs down; delete removes the save.
