# Story 019: Side characters and choices with consequences

> **Epic**: longer-game
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

## Context

**Requirement**: The user asked for optional side characters who give a different kind of evidence, and for choices that change what later floors offer and give the endings more meaning.

---

## Acceptance Criteria

- [x] Dialogue can set a named flag, show or hide choices by flag, redirect by flag, and score a right or wrong decision, all from data; flags are saved and restored with the game (older saves load with none).
- [x] Characters can appear or vanish by flag on a floor.
- [x] Floor 1: after handing over the ledger the clerk asks what the player will do with their name; "keep your name out of it" and "I may need your name" set different flags.
- [x] Floor 3: a campaign worker offers an envelope; taking it counts as a wrong choice, refusing as a right choice, and it is not offered twice.
- [x] Three bonus evidence items (a leaked email from an anonymous source on floor 2, a sworn statement from the former clerk on floor 4 who appears only if their name was protected, a folder from a whistleblower on floor 5 who trusts only a player who did not take the envelope), each with an icon and a fact-check.
- [x] Each bonus item is a shortcut that counters one hard several-proof lie on its own (floors 4, 5 and 6); the long way still works.
- [x] The ending screen says what the player's choices led to.
- [x] A recorded keyboard-only run makes the choices, meets all four new characters, verifies the bonus items and uses a shortcut.

---

## Out of Scope

- Mini-games, a pressure mechanic, achievements (listed for later).

---

## Files

- `src/dialogue/dialogue_runner.gd`, `src/game/game_session.gd`, `src/game/save_game.gd`, `src/game/endings.gd`
- `src/showdown/boss_data.gd`, `showdown.gd`, `showdown_screen.gd`; `src/world/floor_layout.gd`, `floor_scene.gd`; `src/ui/ending_screen.gd/.tscn`
- `data/evidence/`, `data/factchecks/`, `data/dialogue/`, `data/bosses/` (three), `data/floors/floor_2.json` to `floor_5.json`, `data/endings.json`
- `tools/art/generate_art.py` (two characters, three icons)

## Test Evidence

**Story Type**: Integration
**Status**: [x] `production/qa/evidence/story-019-choices-evidence.md`, screenshots in `production/qa/evidence/story-019-choices/`

---

## Dependencies

- Depends on: `production/epics/longer-game/story-018-philippine-cases.md`

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 8/8 passing
**Deviations**: The catalog grew from 18 to 21 evidence items, so a full clear without the bonus items now reads "18 of 21". The last-lie showdown message now includes the boss's reaction (the shortcut reaction for shortcut items).
**Reviewed by**: self, no independent review
