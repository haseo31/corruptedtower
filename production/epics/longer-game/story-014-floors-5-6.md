# Story 014: Floors 5 and 6 and difficulty

> **Epic**: longer-game
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Longer game (Issue-Based Floors: Misuse of public funds, Lack of transparency; Progressive Difficulty)
**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). Mostly data.

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

- [ ] Floor 5 (Misuse of public funds) and floor 6 (Lack of transparency) each have their own layout, NPCs (3 each), 3 new evidence items, fact-check challenges, a desk clue and a boss.
- [ ] Bosses get harder floor by floor: the lie counts for floors 1 to 6 are 2, 3, 3, 4, 4, 5, and the Cover-up maximum stays 3.
- [ ] From floor 3 on, each fact-check challenge includes one tempting source that looks reliable but is not the answer, so the player must read carefully.
- [ ] A boss from floor 4 on has at least one lie that needs two different evidence items together (both presented, in either order) to be exposed.
- [ ] Floor 6's boss is the last boss and ends the run.
- [ ] Every item, challenge, dialogue and boss counter id resolves.
- [ ] A recorded keyboard-only run completes floors 5 and 6, with the ending score at 18 of 18 when everything is verified.

---

## Implementation Notes

- A "needs two items" lie is a new data shape (`counter_all`); the showdown rules gain a small, testable extension.
- Keep rules in `Showdown`/`BossData`; the UI only shows progress ("1 of 2").

---

## Out of Scope

- New mini-game types.
- Endings and the title screen (story 015).

---

## Files

- `data/floors/floor_5.json`, `data/floors/floor_6.json`, `src/world/floor_5.tscn`, `src/world/floor_6.tscn`
- `src/showdown/showdown.gd`, `src/showdown/boss_data.gd`, `src/showdown/showdown_screen.gd`
- `data/evidence/evidence.json`, `data/factchecks/factchecks.json`, `data/dialogue/dialogues.json`, `data/bosses/`

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/progression/floors_5_6_test.gd` OR a playtest doc

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/longer-game/story-013-floors-3-4.md`
- Unlocks: `production/epics/longer-game/story-015-title-and-endings.md`
