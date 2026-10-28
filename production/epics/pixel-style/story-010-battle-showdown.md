# Story 010: Battle-style showdown

> **Epic**: pixel-style
> **Status**: Ready
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 5 (boss showdown), Art & audio direction
**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). Check `docs/engine-reference/godot/` before using any API.

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

- [ ] The showdown fills the 480×320 view in a battle layout: the boss sprite (2×) at the upper right, the player's back view (2×) at the lower left, a plain background, and a bordered text box along the bottom.
- [ ] A bordered boss panel at the upper left shows the boss's name and a Cover-up bar that fills as the meter rises (with the number as text too).
- [ ] The boss's current lie is shown in the bottom text box, and feedback replaces it after each turn.
- [ ] Evidence is chosen from a bordered menu at the lower right with the "▶" marker; with more items than fit, the menu scrolls and keeps the selection visible.
- [ ] Each item shows whether it is verified, and unverified evidence still counts as wrong (rules unchanged).
- [ ] Countering a lie flashes the boss; a wrong answer shakes the screen briefly. Both are short and skippable, and can be turned off with an `@export`/setting.
- [ ] Winning shows "Continue", losing shows "Try again", Esc leaves; all work with the keyboard only.
- [ ] A retained screenshot of the opening, a wrong turn, a win and a loss is saved as evidence.

---

## Implementation Notes

- Rules stay in `Showdown`; this story changes only `showdown_screen.gd` and its scene.
- Reuse the theme from story 009 and the character sheets from story 007.

---

## Out of Scope

- Sound effects and music.
- Multiple lies at once or other new rules.

---

## Files

- `src/showdown/showdown_screen.gd`, `src/showdown/showdown_screen.tscn`
- `assets/art/` (boss back-view and player back-view sprites, if not yet generated)

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: UI
**Required evidence**: a retained screenshot of each screen state touched, in `production/qa/evidence/`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/pixel-style/story-009-ui-theme-and-dialogue.md`
- Unlocks: `production/epics/pixel-style/story-011-remaining-screens.md`
