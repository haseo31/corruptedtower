# Story 006: Two floors and ending screen

> **Epic**: the-corrupted-tower
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 6
**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). Check `docs/engine-reference/godot/` before using any API.

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From the brief's Player goal & fail state and MVP feature 6:*

- [ ] Floor 1 (Bribery) has a layout, NPCs, evidence and a boss, using the systems from stories 001–005.
- [ ] Floor 2 (Disinformation) has the same, with a different boss and different lies.
- [ ] Defeating floor 1's boss unlocks the transition to floor 2.
- [ ] Defeating floor 2's boss ends the run and opens the ending screen.
- [ ] The ending screen shows how much verified evidence the player gathered out of the total available.
- [ ] The ending screen text is a single score-based outcome (one ending only for the MVP).
- [ ] The player can start a new run from the ending screen.
- [ ] Each floor is playable from start to boss using only the keyboard.

---

## Implementation Notes

- Reuse the same scene, data and rules for both floors; floors differ by data.
- Count evidence from the inventory (story 002); do not track a separate score.

---

## Out of Scope

- Floors beyond the first two.
- Multiple endings, save system, voice acting.

---

## Files

- `src/showdown/showdown_screen.gd`
- `src/showdown/showdown_screen.tscn`
- `src/ui/ending_screen.gd`
- `src/ui/ending_screen.tscn`
- `data/bosses/bribery_boss.json`
- `data/bosses/disinformation_boss.json`
- `data/evidence/evidence.json` (3 new items)
- `data/factchecks/factchecks.json` (3 new challenges)
- `data/dialogue/dialogues.json` (archivist reworked, intern added)
- `data/floors/floor_1.json`, `data/floors/floor_2.json` (bosses, locked stairs, floor 2 NPCs and clue)
- `src/game/game_session.gd` (defeated bosses, challenges)
- `src/evidence/evidence_inventory.gd` (verified_count, catalog_size)
- `src/ui/inventory_panel.gd` (focus, selection kept on refresh)
- `src/ui/evidence_screen.gd` (open, Esc, focus return)
- `src/dialogue/dialogue_runner.gd` (message_dialogue)
- `src/world/floor_layout.gd`, `src/world/floor_player.gd`, `src/world/floor_scene.gd`, `src/world/floor.tscn` (bosses, locks, I key, modals, ending)

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal` waives tests as advisory.*

**Story Type**: Integration
**Required evidence**: `tests/integration/progression/two_floor_run_test.gd` OR a playtest doc

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/the-corrupted-tower/story-001-boss-showdown.md`, `production/epics/the-corrupted-tower/story-002-evidence-inventory.md`, `production/epics/the-corrupted-tower/story-003-fact-check-minigame.md`, `production/epics/the-corrupted-tower/story-004-walkable-floor.md`, `production/epics/the-corrupted-tower/story-005-npc-dialogue.md`
- Unlocks: None

---

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 8/8 passing (none deferred)
**Deviations**: ADVISORY — all UI text (showdown and ending screens, dialogue notices) is hardcoded (no localization system yet); the evidence inventory, defeated bosses, dialogues and challenges are held in static variables (`GameSession`) rather than injected; the art is placeholder shapes; the ending shows the score but has a single outcome text (one ending is the MVP scope). Files from stories 001-005 were edited (`floor_layout.gd`, `floor_player.gd`, `floor_scene.gd`, `floor.tscn`, `inventory_panel.gd`, `evidence_screen.gd`, `evidence_inventory.gd`, `dialogue_runner.gd`, `game_session.gd`, and the data files); all are listed under Files. The first full keyboard run exposed a bug from story 002 (the evidence list lost its selection after each refresh); it was fixed in `inventory_panel.gd`.
**Test Evidence**: waived at qa.level minimal; data consistency and rules checked by throwaway headless scenario runs (20 checks, not kept in the repo); one keyboard-only playthrough of the whole game plus a lose and Try again capture in production/qa/evidence/story-006-floors-and-ending/ (01 to 12)
**Reviewed by**: self, no independent review
