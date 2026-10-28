# Story 020: Filipino (Tagalog) version

> **Epic**: longer-game
> **Status**: Complete
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

## Context

**Requirement**: The user asked for a Tagalog version, so that more Filipino players can understand the lessons.

---

## Acceptance Criteria

- [x] A Language option in Settings (English, Filipino) that is saved and takes effect at once.
- [x] Every sentence the game shows has a Filipino version: menus, messages, the how-to guide, characters' dialogue, evidence, fact-checks, bosses, floors, endings, case files, the Tower Journal and the closing guide.
- [x] The translation is a table of English sentence to Filipino sentence (`data/translations/fil/`), applied when data loads, so no game logic, id, answer or save file changes with the language.
- [x] A sentence with no translation shows in English, never blank.
- [x] The Filipino text fits the screens (title, settings, guide, dialogue, evidence, showdown, case files, ending), using only the characters the pixel font draws.
- [x] `design/translation-review-fil.md` says the text is an unreviewed draft and how a Filipino speaker can review and fix it.
- [x] English play is unchanged (existing tests still pass).

---

## Out of Scope

- A review by a native speaker or a lawyer (recommended before wide release).
- Other languages (the table format supports them: add a folder under `data/translations/` and one line in `Tr.LANGUAGES`).

---

## Files

- `src/game/tr.gd`, `src/game/game_settings.gd`, `src/ui/settings_panel.gd`, `src/ui/title_screen.gd`
- Every data loader (`dialogue_runner.gd`, `evidence_inventory.gd`, `fact_check_challenge.gd`, `boss_data.gd`, `floor_layout.gd`, `lessons.gd`, `endings.gd`) and the screens' fixed text.
- `data/translations/fil/` (six files, 685 sentences), `design/translation-review-fil.md`

## Test Evidence

**Story Type**: UI
**Status**: [x] `production/qa/evidence/story-020-filipino-evidence.md`, screenshots in `production/qa/evidence/story-020-filipino/`

---

## Dependencies

- Depends on: `production/epics/longer-game/story-019-side-characters-and-choices.md`

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 7/7 passing
**Deviations**: Wrapping buttons now get a real minimum width (settings and journal), and text panels recompute their size when they open: a layout fault found by the Filipino text, harmless in English.
**Reviewed by**: self, no independent review; the Filipino text is an unreviewed draft.
