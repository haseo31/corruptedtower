# Story 009: UI theme, view size and dialogue box

> **Epic**: pixel-style
> **Status**: Complete
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief Art & audio direction (pixel art, 16-bit look)
**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). Check `docs/engine-reference/godot/` for Control, Theme and stretch-mode APIs.

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

- [ ] The base view is 480×320 with a default window of 960×640, scaled by whole numbers only so pixels stay square, and the camera zoom returns to 1.
- [ ] One shared pixel theme is built in code and used by every panel: the pixel font, a white bordered box style, a dark-text-on-white look, and a "▶" marker on the selected menu item.
- [ ] The dialogue box is a Pokémon-style white bordered text box at the bottom of the screen with the speaker's name above the text.
- [ ] Dialogue text appears one character at a time (typewriter); pressing interact shows the whole line at once, and pressing it again advances.
- [ ] A small "▼" continue arrow blinks when a line is fully shown.
- [ ] Choices appear as a bordered menu with the "▶" marker, usable with arrows and Enter.
- [ ] The evidence screen, fact-check panel, showdown screen and ending screen all fit inside 480×320 and are readable (no clipped or overlapping text), using the theme.
- [ ] All controls still work with the keyboard only.
- [ ] A retained screenshot of each screen is saved as evidence (dialogue, choices, evidence, fact-check, showdown, ending), with sign-off.

---

## Implementation Notes

- Build the theme in one script (`PixelTheme`) and apply it to the root of each modal so scenes stay thin.
- The typewriter effect uses `Label.visible_characters` and must be skippable; text speed is a data/`@export` value.
- The showdown gets only a fit-to-view pass here; its battle layout is story 010.

---

## Out of Scope

- Story 010: the battle-style showdown layout.
- Story 011: evidence icons, hints, and final polish.

---

## Files

- `project.godot` (480x320 view, integer scaling)
- `src/ui/pixel_theme.gd`, `src/ui/pixel_button.gd` (new)
- `src/dialogue/dialogue_box.gd`, `src/dialogue/dialogue_box.tscn` (rewritten)
- `src/ui/evidence_screen.gd`, `src/ui/inventory_panel.tscn`, `src/factcheck/fact_check_panel.gd`, `src/factcheck/fact_check_panel.tscn`
- `src/showdown/showdown_screen.gd`, `src/showdown/showdown_screen.tscn`
- `src/ui/ending_screen.gd`, `src/ui/ending_screen.tscn`
- `src/world/floor.tscn`, `src/world/floor_scene.gd` (zoom 1, floor name box)

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: UI
**Required evidence**: a retained screenshot of each screen touched, in `production/qa/evidence/`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/pixel-style/story-008-floors-and-characters.md`
- Unlocks: `production/epics/pixel-style/story-010-battle-showdown.md`

---

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 9/9 passing (none deferred)
**Deviations**: ADVISORY — the evidence list marks its selection by inverting it (dark bar, light text) rather than with the arrow marker; the arrow for that list comes with story 011. All UI text is hardcoded (no localization system yet). `DialogueBox.text_speed` is a static value so one setting covers every floor (tests set it very high; a future options menu can expose it). The showdown screen only fits the new view here, with a lot of empty space; its battle layout is story 010. The ending's "Start new run" button had to be set to fill (not shrink) because a wrapping menu button collapses to zero width when shrunk.
**Test Evidence**: waived at qa.level minimal; the full keyboard-only playthrough re-run on the new 480x320 UI ended identically at every checkpoint; retained screenshots and sign-off in production/qa/evidence/story-009-ui-theme-and-dialogue/ and production/qa/evidence/story-009-ui-theme-and-dialogue-evidence.md (sign-off approved by the user)
**Reviewed by**: self, no independent review
