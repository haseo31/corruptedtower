# Story 016: Web export

> **Epic**: longer-game
> **Status**: Ready
> **Layer**: Presentation
> **Type**: Config/Data
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Distribution to students and teachers (project PDF secondary audience) without an install
**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). Web export needs the matching export templates installed in the editor; check `docs/engine-reference/godot/` for the web export notes.

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

- [ ] A Web export preset exists in the project and `commands.build` in `project.yaml` names it.
- [ ] A single-thread web build is produced into `build/web/` (ignored by Git) with one command.
- [ ] The built game opens in a browser from a local web server, shows the title screen, and the keyboard works (arrows, E, Enter, I, Esc).
- [ ] A full run from the title screen to the ending works in the browser.
- [ ] Save and Continue work in the browser and survive a page reload.
- [ ] The browser console shows no errors during the run.
- [ ] The README gains a short "play in a browser" section with the build and hosting steps (for example itch.io or GitHub Pages).
- [ ] A retained screenshot of the game running in a browser is saved as evidence.

---

## Implementation Notes

- Prefer the single-thread export so it runs on any static host without special headers.
- If the export templates are not installed, this story stops and asks the user to install them from the editor (Editor > Manage Export Templates); it never downloads them silently.

---

## Out of Scope

- Mobile touch controls, hosting setup for the user.

---

## Files

- `export_presets.cfg`, `project.yaml` (`commands.build`), `.gitignore` (`/build/`)
- `README.md` (short web section)

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Config/Data
**Required evidence**: a smoke check pass (`production/qa/smoke-*.md`) and a browser screenshot

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/longer-game/story-015-title-and-endings.md`
- Unlocks: None
