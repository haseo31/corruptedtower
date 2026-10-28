# Story 013: Floors 3 and 4

> **Epic**: longer-game
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Longer game (Issue-Based Floors: Vote-buying, Nepotism)
**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). This story is mostly data.

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

- [x] Floor 3 (Vote-buying) and floor 4 (Nepotism) each have their own layout, with a different look from the floors before (carpet, desk and wall variations).
- [x] Each floor has 3 NPCs with short interviews (choices that change the reply), 3 new evidence items, and one desk clue.
- [x] Each new evidence item has a fact-check challenge with 3 sources and an explanation.
- [x] Each floor has a boss with its own name, look and 3 lies, each countered by evidence found on that floor.
- [x] Floor 2's stairs up lead to floor 3, floor 3's to floor 4, and each is locked until that floor's boss is exposed.
- [x] Every item, challenge, dialogue and boss counter id resolves (a data check passes with no missing reference).
- [x] The player can finish floors 3 and 4 with the keyboard only, in a recorded run.
- [x] The total number of evidence items is shown correctly on the ending score (12 of 12 at this point).

---

## Implementation Notes

- Reuse existing systems; add only data, new character sheets, and layout variety.
- Topics and example evidence: vote-buying (cash-for-votes receipts, a fake poll), nepotism (a relative's hiring file, a fake qualification list).

---

## Out of Scope

- Floors 5 and 6 (story 014).
- New mini-game types.

---

## Files

- `data/floors/floor_3.json`, `data/floors/floor_4.json`, `src/world/floor_3.tscn`, `src/world/floor_4.tscn`
- `data/evidence/evidence.json`, `data/factchecks/factchecks.json`, `data/dialogue/dialogues.json`
- `data/bosses/` (two boss files), `tools/art/generate_art.py` and `assets/art/` (new sheets)

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/progression/floors_3_4_test.gd` OR a playtest doc

**Status**: [x] Created: `production/qa/evidence/story-013-floors-3-4-evidence.md`, screenshots in `production/qa/evidence/story-013-floors-3-4/`

---

## Dependencies

- Depends on: `production/epics/longer-game/story-012-navigation-and-saves.md`
- Unlocks: `production/epics/longer-game/story-014-floors-5-6.md`

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 8/8 passing
**Deviations**: Out of scope, for awareness: `src/world/floor_layout.gd` and `src/world/floor_scene.gd` gained a floor-theme field the file list did not name.
**Test Evidence**: waived at qa.level minimal; playtest record `production/qa/evidence/story-013-floors-3-4-evidence.md` with screenshots in `production/qa/evidence/story-013-floors-3-4/`
**Reviewed by**: self, no independent review
