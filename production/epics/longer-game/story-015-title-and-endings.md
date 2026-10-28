# Story 015: Title screen and multiple endings

> **Epic**: longer-game
> **Status**: Complete
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Longer game (Multiple Endings from the project PDF)
**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). Check `docs/engine-reference/godot/` before using any API.

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

- [x] The game opens on a pixel-style title screen with the game name, the tower, and a menu: New Game (shown as Play), Continue (only when a save exists), Quit (shown as Exit), plus How to play and Settings.
- [x] New Game starts a clean run on floor 1; Continue loads the save from story 012.
- [x] The pause menu's Quit returns to the title screen.
- [x] There are 3 endings chosen by the share of choices that were right the first time (changed from the share of evidence verified, which cannot vary: the player must verify at least 17 of 18 to win): 90% or more, 60% to under 90%, and under 60%.
- [x] Each ending has its own title, text, and a short civic message that matches what the player did.
- [x] The thresholds and texts are in a data file, not code.
- [x] The ending screen still shows "Evidence verified: N of M" and a button to return to the title screen.
- [x] Everything works with the keyboard only, and each of the 3 endings was reached in a test.

---

## Implementation Notes

- Keep ending selection in a small testable function (score in, ending id out).
- The main scene in `project.godot` becomes the title screen.

---

## Out of Scope

- Music, settings menus, language options.

---

## Files

- `src/ui/title_screen.gd`, `src/ui/title_screen.tscn`
- `src/ui/ending_screen.gd`, `src/ui/ending_screen.tscn`, `data/endings.json`
- `src/ui/pause_menu.gd`, `project.godot` (main scene)

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: UI
**Required evidence**: a retained screenshot of each screen touched, in `production/qa/evidence/`

**Status**: [x] Created: `production/qa/evidence/story-015-title-menu-evidence.md` and `production/qa/evidence/story-015-endings-evidence.md`, screenshots in `story-015-title-menu/` and `story-015-endings/`

---

## Dependencies

- Depends on: `production/epics/longer-game/story-014-floors-5-6.md`
- Unlocks: `production/epics/longer-game/story-016-web-export.md`

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 8/8 passing
**Deviations**: Out of scope, for awareness: the title screen gained How to play and Settings, as the user asked (with `GameSettings`, a settings file, and the Music and SFX buses). The ending is chosen by first-try accuracy, not verified share (see the changed criterion above and the evidence note); this adds `GameSession.record_choice` and two counts in the save file (older saves load as zero). Music and settings menus were listed out of scope but were requested by the user.
**Test Evidence**: waived at qa.level minimal; UI evidence retained as screenshots in `production/qa/evidence/story-015-title-menu/` and `story-015-endings/` with the two evidence notes
**Reviewed by**: self, no independent review
