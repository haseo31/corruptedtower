# Story 004: Walkable floor

> **Epic**: the-corrupted-tower
> **Status**: Complete
> **Layer**: Core
> **Type**: Visual/Feel
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 1
**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). Check `docs/engine-reference/godot/` before using any API.

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From the brief's Core loop and MVP feature 1:*

- [ ] The player character moves one grid tile at a time with the keyboard (arrow keys or WASD).
- [ ] Movement is smooth between tiles and the player always ends aligned to the grid.
- [ ] Walls and furniture block movement.
- [ ] The player faces the direction of the last move and an idle state shows when still.
- [ ] A transition tile moves the player to another floor scene and back.
- [ ] The camera follows the player and stays inside the floor bounds.
- [ ] The project has a main scene set, so the game runs from the editor with one key.
- [ ] A retained screenshot of the floor with the player is saved as evidence.

---

## Implementation Notes

- Use `CharacterBody2D` or tile-based movement with a `TileMapLayer`; check the 4.7 reference docs for the current TileMap API before coding.
- Set `run/main_scene` in `project.godot` once the floor scene exists.

---

## Out of Scope

- Story 005: NPCs and dialogue on the floor.
- Story 006: the specific Bribery and Disinformation floor layouts.

---

## Files

- `src/world/floor_layout.gd`
- `src/world/floor_player.gd`
- `src/world/floor_scene.gd`
- `src/world/floor.tscn`
- `src/world/floor_1.tscn`
- `src/world/floor_2.tscn`
- `data/floors/floor_1.json`
- `data/floors/floor_2.json`
- `project.godot` (main scene)

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal` waives tests as advisory, but the screenshot is not waived.*

**Story Type**: Visual/Feel
**Required evidence**: a retained screenshot in `production/qa/evidence/` + sign-off in `production/qa/evidence/walkable-floor-evidence.md`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: `production/epics/the-corrupted-tower/story-005-npc-dialogue.md`

---

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 6/8 passing (AC2 smooth movement and AC4's idle bob DEFERRED — requires playtest session)
**Deviations**: ADVISORY — placeholder-drawing sizes, colors and the idle bob are literals in `floor_player.gd` and `floor_scene.gd` (floors and `move_time` are data / `@export`); no localization system yet for the floor name's UI text (it comes from the data file); transitions use a static variable (`FloorScene.arrival_cell`) to pass the arrival cell between scenes.
**Test Evidence**: waived at qa.level minimal; layout rules checked by a throwaway headless scenario run (not kept in the repo); retained screenshots and sign-off in production/qa/evidence/story-004-walkable-floor/ and production/qa/evidence/story-004-walkable-floor-evidence.md (sign-off approved by the user)
**Reviewed by**: self, no independent review
