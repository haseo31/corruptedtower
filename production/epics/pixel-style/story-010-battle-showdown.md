# Story 010: Battle-style showdown

> **Epic**: pixel-style
> **Status**: Complete
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

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

- `src/showdown/showdown_screen.gd`, `src/showdown/showdown_screen.tscn` (rewritten)
- `src/showdown/battle_sprite.gd`, `src/showdown/battle_backdrop.gd` (new)
- `src/showdown/boss_data.gd`, `data/bosses/bribery_boss.json`, `data/bosses/disinformation_boss.json` (sprite field)
- `src/ui/pixel_theme.gd` (progress bar style)
- `src/world/character_sprites.gd` (frame_size)

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

---

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 8/8 passing (none deferred)
**Deviations**: ADVISORY — AC3: the feedback line is shown above the boss's current lie instead of replacing it, so the lie stays visible (accepted by the user). The flash and shake switch is a static `ShowdownScreen.reduce_motion` (not an `@export`) so a future options menu can set it. Showdown text is hardcoded (no localization system yet). The menu entries are linked to each other by hand (`focus_neighbor_*`) because Godot's arrow-key navigation skips an entry that is scrolled completely out of view; a regression run caught that the sixth evidence item was unreachable by keyboard before this fix. The player's back view reads dark at 2x (mostly hair and cap).
**Test Evidence**: waived at qa.level minimal; the full keyboard-only playthrough re-run on the new screen ended identically at every checkpoint; retained screenshots and sign-off in production/qa/evidence/story-010-battle-showdown/ and production/qa/evidence/story-010-battle-showdown-evidence.md (sign-off approved by the user)
**Reviewed by**: self, no independent review
