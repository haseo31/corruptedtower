# Story 015: Title screen and multiple endings

> **Epic**: longer-game
> **Status**: Ready
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

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

- [ ] The game opens on a pixel-style title screen with the game name, the tower, and a menu: New Game, Continue (only when a save exists), Quit.
- [ ] New Game starts a clean run on floor 1; Continue loads the save from story 012.
- [ ] The pause menu's Quit returns to the title screen.
- [ ] There are 3 endings chosen by the share of evidence verified: 90% or more, 60% to under 90%, and under 60%.
- [ ] Each ending has its own title, text, and a short civic message that matches what the player did.
- [ ] The thresholds and texts are in a data file, not code.
- [ ] The ending screen still shows "Evidence verified: N of M" and a button to return to the title screen.
- [ ] Everything works with the keyboard only, and each of the 3 endings was reached in a test.

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

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/longer-game/story-014-floors-5-6.md`
- Unlocks: `production/epics/longer-game/story-016-web-export.md`
