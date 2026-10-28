# Story 012: Floor navigation and save/load

> **Epic**: longer-game
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Longer game (6 floors need navigation and a way to stop and resume)
**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). Check `docs/engine-reference/godot/` for file access and `user://` behaviour.

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

- [ ] Every floor except the first has stairs down, and every floor except the last has stairs up that stay locked until that floor's boss is exposed.
- [ ] Going up and down always places the player beside the matching stairs on the other floor.
- [ ] A pause menu opens with Esc when no panel is open, with: Resume, Save, Load, and Quit to title/desktop.
- [ ] Saving writes the evidence collected (with verified flags), defeated bosses, the current floor and the player's cell to a file under `user://`.
- [ ] Loading restores exactly that state: inventory, defeated bosses, floor and position.
- [ ] A missing or corrupt save file shows a clear message and does not crash.
- [ ] The save file is versioned so a later change can detect an old save.
- [ ] Save and load work with the keyboard only, and a save made after beating floor 1 loads back to floor 1 with the stairs unlocked.

---

## Implementation Notes

- Put saving in one class (`SaveGame`) so it is testable without a scene; the pause menu only calls it.
- Keep `GameSession` as the holder of state, and add `to_dict()` and `from_dict()` on it.

---

## Out of Scope

- Several save slots, cloud saves.
- The title screen (story 015); Quit goes to the desktop until it exists.

---

## Files

- `src/game/save_game.gd`, `src/ui/pause_menu.gd`, `src/ui/pause_menu.tscn` (new)
- `src/game/game_session.gd` (defeated_bosses, restore), `src/evidence/evidence_inventory.gd` (knows)
- `src/world/floor_scene.gd` (Esc menu, save and load, safe arrival cell), `src/world/floor.tscn` (pause menu)
- `data/floors/floor_1.json`, `data/floors/floor_2.json` (hint text: Esc opens the menu)

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/save/save_game_test.gd` OR a playtest doc

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/pixel-style/story-011-remaining-screens.md`
- Unlocks: `production/epics/longer-game/story-013-floors-3-4.md`

---

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 8/8 passing (none deferred)
**Deviations**: ADVISORY — "Quit" ends the game on the desktop; returning to a title screen waits for story 015, and the web export (story 016) will need a different exit. Only two floors exist, so the stairs logic has so far run between those two; the pairing check (every staircase has a matching one beside its arrival cell) will cover floors 3-6 as they arrive. If a saved or arrival cell is not walkable, the player falls back to the floor's spawn point. All UI text is hardcoded (no localization system yet). `SaveGame.save_path` is a static value so tests can point it at a scratch file.
**Test Evidence**: waived at qa.level minimal; a playtest record (keyboard-only: save after beating floor 1, wipe, load) and screenshots in production/qa/evidence/story-012-navigation-and-saves/ and production/qa/evidence/story-012-navigation-and-saves-evidence.md; 22 headless save-rule checks and the full keyboard-only playthrough, all run against a scratch save file (not kept in the repo)
**Reviewed by**: self, no independent review
