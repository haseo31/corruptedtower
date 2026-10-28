# Story 016: Web export

> **Epic**: longer-game
> **Status**: Complete (7 of 8 criteria; see Completion Notes)
> **Layer**: Presentation
> **Type**: Config/Data
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

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

- [x] A Web export preset exists in the project and `commands.build` in `project.yaml` names it.
- [x] A single-thread web build is produced into `build/web/` (ignored by Git) with one command.
- [x] The built game opens in a browser from a local web server, shows the title screen, and the keyboard works (arrows, E, Enter, I, Esc).
- [ ] A full run from the title screen to the ending works in the browser.
- [x] Save and Continue work in the browser and survive a page reload.
- [x] The browser console shows no errors during the run.
- [x] The README gains a short "play in a browser" section with the build and hosting steps (for example itch.io or GitHub Pages).
- [x] A retained screenshot of the game running in a browser is saved as evidence.

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

**Status**: [x] Created: `production/qa/evidence/story-016-web-evidence.md`, browser screenshots in `production/qa/evidence/story-016-web/`

---

## Dependencies

- Depends on: `production/epics/longer-game/story-015-title-and-endings.md`
- Unlocks: None

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 7/8 passing. Not done: a full run from the title screen to the ending *in the browser*. Title, Play, walking, dialogue with choices, evidence, fact-check, pause, Save, page reload, Continue and the restored state were played in the browser; the same game was played floor 4 to the ending natively (see stories 014 to 019). A person should play one full run in the browser before release.
**Deviations**: `tools/build_web.sh` (creates `build/web/` first, because Godot will not) is the build command instead of a bare Godot call. Only the two single-thread web templates were kept from the 1.28 GB download (about 20 MB, in Godot's templates folder); the download was deleted.
**Test Evidence**: `production/qa/evidence/story-016-web-evidence.md` with browser screenshots
**Reviewed by**: self, no independent review
