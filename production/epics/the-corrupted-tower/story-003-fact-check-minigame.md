# Story 003: Fact-check mini-game

> **Epic**: the-corrupted-tower
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 4
**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). Check `docs/engine-reference/godot/` before using any API.

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From the brief's Core loop and MVP feature 4:*

- [ ] Opening an unverified evidence item starts a fact-check challenge for it.
- [ ] The challenge shows a claim with several sources or statements; the player picks the fake or unreliable one.
- [ ] A correct answer marks the evidence item verified in the inventory.
- [ ] A wrong answer leaves the item unverified, explains why the choice was wrong, and allows a retry.
- [ ] Challenge content (claim, options, correct answer, explanation) lives in data files.
- [ ] Only one mini-game type exists; adding more is out of scope.
- [ ] The challenge can be completed with keyboard only.

---

## Implementation Notes

- Reuse the inventory's `evidence_verified` signal path from story 002; do not duplicate state.
- Keep the answer-checking logic separate from the UI scene so it is testable.

---

## Out of Scope

- Additional mini-game types.
- Story 005: how the player reaches an NPC's evidence.

---

## Files

- `src/factcheck/fact_check_challenge.gd`
- `src/factcheck/fact_check_session.gd`
- `src/factcheck/fact_check_panel.gd`
- `src/factcheck/fact_check_panel.tscn`
- `src/ui/evidence_screen.gd`
- `src/ui/evidence_screen.tscn`
- `src/ui/inventory_panel.gd` (added `evidence_selected` signal)
- `data/factchecks/factchecks.json`

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal` waives tests as advisory.*

**Story Type**: Integration
**Required evidence**: `tests/integration/factcheck/fact_check_test.gd` OR a playtest doc

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/the-corrupted-tower/story-002-evidence-inventory.md`
- Unlocks: `production/epics/the-corrupted-tower/story-006-floors-and-ending.md`

---

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 7/7 passing (none deferred)
**Deviations**: ADVISORY — panel text is hardcoded (no localization system yet) and there is no gamepad or open-key binding (arrives with the floor, story 004). The wrong-answer explanation also reveals which source is the fake, so a retry is easy. `src/ui/inventory_panel.gd` from story 002 was edited to add the `evidence_selected` signal (listed under Files).
**Test Evidence**: waived at qa.level minimal; rules checked by a throwaway headless scenario run (not kept in the repo); keyboard-only run captured in production/qa/evidence/story-003-fact-check-minigame/ (01-challenge-open.png, 02-wrong-answer.png, 03-verified.png)
**Reviewed by**: self, no independent review
