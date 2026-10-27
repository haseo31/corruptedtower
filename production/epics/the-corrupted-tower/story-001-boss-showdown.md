# Story 001: Boss showdown

> **Epic**: the-corrupted-tower
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 5
**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). Check `docs/engine-reference/godot/` before using any API.

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From the brief's Player goal & fail state and MVP feature 5:*

- [ ] A showdown starts against a boss that has a list of "lies", each countered by specific evidence.
- [ ] Each turn the player picks one evidence item from their inventory to present.
- [ ] Presenting evidence that counters the boss's current lie removes that lie.
- [ ] Presenting wrong or unverified evidence fills the boss's "Cover-up" meter by a fixed amount.
- [ ] The player wins when every lie is removed; the showdown ends with a win result.
- [ ] The player loses when the Cover-up meter is full; the showdown ends with a lose result.
- [ ] After a loss the showdown can be restarted, and evidence collected before it is kept.
- [ ] Boss lies, counter-evidence mapping and meter values live in data files, not code.
- [ ] Showdown logic runs without any scene or UI so it can be unit tested.

---

## Implementation Notes

- Build the rules as a plain GDScript class (`RefCounted`) separate from the UI scene.
- Use placeholder evidence data until story 002 provides the inventory.
- Static typing everywhere; signals in past tense (`lie_removed`, `cover_up_filled`).

---

## Out of Scope

- Story 002: the real evidence inventory.
- Story 006: the specific Bribery and Disinformation bosses.

---

## Files

- `src/showdown/boss_data.gd`
- `src/showdown/showdown.gd`
- `data/bosses/placeholder_boss.json`

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal` waives tests as advisory.*

**Story Type**: Logic
**Required evidence**: `tests/unit/showdown/showdown_test.gd`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: `production/epics/the-corrupted-tower/story-002-evidence-inventory.md`, `production/epics/the-corrupted-tower/story-006-floors-and-ending.md`

---

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 9/9 passing (none deferred)
**Deviations**: ADVISORY — `cover_up_max` has a default literal of 3 in `boss_data.gd` (data always overrides it). AC2 is met by the one-evidence-id-per-turn rules; the inventory picker UI arrives with story 002.
**Test Evidence**: waived at qa.level minimal; rules checked by a throwaway headless scenario run (not kept in the repo)
**Reviewed by**: self, no independent review
