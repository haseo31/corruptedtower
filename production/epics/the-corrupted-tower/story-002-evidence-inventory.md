# Story 002: Evidence inventory

> **Epic**: the-corrupted-tower
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 3
**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). Check `docs/engine-reference/godot/` before using any API.

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From the brief's Core loop and MVP feature 3:*

- [ ] The player can collect an evidence item; it appears in the inventory.
- [ ] Each item has a title, description and a verified or unverified state; new items start unverified.
- [ ] An item can be marked verified (called by the fact-check mini-game, story 003).
- [ ] The same item cannot be collected twice.
- [ ] The inventory can be opened and shows all items with their verified state.
- [ ] The showdown (story 001) reads evidence from this inventory instead of placeholders.
- [ ] Evidence is kept when a showdown is lost and restarted.
- [ ] Evidence definitions live in data files.

---

## Implementation Notes

- Make the inventory a plain `RefCounted` class with signals (`evidence_collected`, `evidence_verified`), shared via an autoload or passed in, so it stays unit testable.
- The inventory view is a Control scene driven by those signals.

---

## Out of Scope

- Story 003: how an item becomes verified.
- Story 005: where evidence is found.

---

## Files

- `src/evidence/evidence_item.gd`
- `src/evidence/evidence_inventory.gd`
- `src/ui/inventory_panel.gd`
- `src/ui/inventory_panel.tscn`
- `data/evidence/evidence.json`
- `src/showdown/showdown.gd` (added `present_from`)

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal` waives tests as advisory.*

**Story Type**: Logic
**Required evidence**: `tests/unit/evidence/evidence_inventory_test.gd`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/the-corrupted-tower/story-001-boss-showdown.md`
- Unlocks: `production/epics/the-corrupted-tower/story-003-fact-check-minigame.md`, `production/epics/the-corrupted-tower/story-005-npc-dialogue.md`

---

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 8/8 passing (none deferred)
**Deviations**: ADVISORY — the panel's text is hardcoded (no localization system yet); the panel has no key or gamepad binding to open it (arrives with the floor, story 004). `src/showdown/showdown.gd` from story 001 was edited to add `present_from` (listed under Files).
**Test Evidence**: waived at qa.level minimal; rules checked by a throwaway headless scenario run (not kept in the repo); screenshot at production/qa/evidence/story-002-evidence-inventory/01-panel00000029.png
**Reviewed by**: self, no independent review
