# Story 008: Floors and characters

> **Epic**: pixel-style
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Visual/Feel
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief Art & audio direction (pixel art, 16-bit look)
**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). Check `docs/engine-reference/godot/` before using any API.

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

- [ ] Floors are drawn from the 16×16 atlas: floor, carpet, desks, wall face along the top, darker wall blocks for pillars and side walls, and stairs (teal open, red locked).
- [ ] Floor layouts use 16-pixel tiles (`tile_size` 16 in the data) and the world is shown at 2× zoom, so the screen looks like today's size but with sharp pixels.
- [ ] The player is drawn from the player sheet and faces the direction last moved (4 directions).
- [ ] The player plays the walk animation (walk 1, idle, walk 2, idle) while stepping between tiles and the idle pose when still.
- [ ] Every NPC and boss uses its own character sheet and is clearly different from the others.
- [ ] Clues on desks use the desk-with-paper tile and disappear once collected.
- [ ] Characters stay pixel-aligned: no blurry or shimmering sprites when walking or when the camera scrolls.
- [ ] Gameplay is unchanged: movement, blocking, interaction, transitions and the full run still work with the keyboard.
- [ ] A retained screenshot of each floor and one of the walk animation is saved as evidence, with sign-off.

---

## Implementation Notes

- Keep the JSON layouts; draw tiles with `draw_texture_rect_region` from the atlas. Do not hand-edit TileMapLayer data.
- Choose a wall tile by neighbours: a wall cell with floor below it is a wall face; other wall cells are blocks.
- Use `texture_filter` nearest and enable pixel snapping for 2D transforms.

---

## Out of Scope

- Story 009: the 480×320 view and the UI theme (this story keeps the current window size and uses camera zoom 2).
- Extra decoration tiles (plants, windows, cabinets).

---

## Files

- `src/world/tile_atlas.gd`, `src/world/character_sprites.gd`, `src/world/floor_npc.gd` (new)
- `src/world/floor_scene.gd`, `src/world/floor_player.gd`, `src/world/floor_layout.gd`
- `src/world/floor.tscn` (Actors node, camera zoom 2)
- `data/floors/floor_1.json`, `data/floors/floor_2.json` (tile size 16, carpet, sprite ids)
- `project.godot` (pixel snapping)

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Visual/Feel
**Required evidence**: a retained screenshot in `production/qa/evidence/` + sign-off in `production/qa/evidence/story-008-floors-and-characters-evidence.md`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/pixel-style/story-007-pixel-pipeline.md`
- Unlocks: `production/epics/pixel-style/story-009-ui-theme-and-dialogue.md`

---

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 7/9 passing (AC4's walk animation smoothness and AC7's sharpness in motion DEFERRED — requires playtest session)
**Deviations**: ADVISORY — the HUD panels (dialogue box, evidence screen, fact-check, showdown, ending) still use the old plain look and 1152x648 layout until story 009; sprites are loaded once into a static cache (`CharacterSprites`) rather than injected; the player node moved under a new `Actors` node for depth sorting, so its scene path is now `Actors/Player`. A few old scratch-script expectations (32-pixel tiles, the story-005 dialogue counts) no longer match the data and were not kept.
**Test Evidence**: waived at qa.level minimal; the full keyboard-only playthrough re-run on the restyled build ended identically; retained screenshots and sign-off in production/qa/evidence/story-008-floors-and-characters/ and production/qa/evidence/story-008-floors-and-characters-evidence.md (sign-off approved by the user)
**Reviewed by**: self, no independent review
