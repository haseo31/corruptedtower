# Story 005: NPC dialogue and interviews

> **Epic**: the-corrupted-tower
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 2
**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). Check `docs/engine-reference/godot/` before using any API.

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From the brief's Core loop and MVP feature 2:*

- [ ] The player can face an NPC and press the interact key to start dialogue.
- [ ] Dialogue shows lines one at a time in a text box, advanced with the keyboard.
- [ ] Some dialogue offers choices (an interview); the choice picked changes what the NPC says.
- [ ] Certain answers give the player an evidence item, which appears in the inventory (unverified).
- [ ] An NPC does not give the same evidence twice.
- [ ] Documents or clues lying on the floor can be picked up with the same interact key.
- [ ] Dialogue content lives in data files, not code.
- [ ] The player cannot move while a dialogue is open.

---

## Implementation Notes

- Keep dialogue data (lines, choices, evidence granted) separate from the dialogue UI scene.
- Call the inventory API from story 002 to add evidence; do not keep a second list.

---

## Out of Scope

- Story 003: verifying the evidence.
- Story 006: the actual NPC cast for the two floors.

---

## Files

- `src/dialogue/dialogue_runner.gd`
- `src/dialogue/dialogue_box.gd`
- `src/dialogue/dialogue_box.tscn`
- `src/game/game_session.gd`
- `data/dialogue/dialogues.json`
- `src/world/floor_layout.gd` (npcs, clues)
- `src/world/floor_player.gd` (interact key, movement lock)
- `src/world/floor_scene.gd` (interaction, NPC and clue drawing)
- `src/world/floor.tscn` (dialogue box)
- `data/floors/floor_1.json`, `data/floors/floor_2.json` (npcs, clues)

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal` waives tests as advisory.*

**Story Type**: Integration
**Required evidence**: `tests/integration/dialogue/dialogue_evidence_test.gd` OR a playtest doc

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/the-corrupted-tower/story-002-evidence-inventory.md`, `production/epics/the-corrupted-tower/story-004-walkable-floor.md`
- Unlocks: `production/epics/the-corrupted-tower/story-006-floors-and-ending.md`

---

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 8/8 passing (none deferred)
**Deviations**: ADVISORY — dialogue UI text ("+ Evidence:" prefix and the pickup line) is hardcoded (no localization system yet); the evidence inventory and loaded dialogues are held in static variables (`GameSession`) so they survive floor changes, instead of being injected; there is no in-game key yet to open the evidence screen (so collected evidence only shows as the "+ Evidence" notice). Floor files from story 004 (`floor_layout.gd`, `floor_player.gd`, `floor_scene.gd`, `floor.tscn`, both floor JSONs) were edited to add NPCs, clues, the interact key and the movement lock (all listed under Files).
**Test Evidence**: waived at qa.level minimal; dialogue rules checked by a throwaway headless scenario run (25 checks, not kept in the repo); keyboard-only run captured in production/qa/evidence/story-005-npc-dialogue/ (01 to 07)
**Reviewed by**: self, no independent review
