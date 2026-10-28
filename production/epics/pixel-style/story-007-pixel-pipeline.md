# Story 007: Pixel art pipeline and pixel font

> **Epic**: pixel-style
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Visual/Feel
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
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). Check `docs/engine-reference/godot/` before using any API (fonts, texture filtering).

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

- [ ] One command (`python tools/art/generate_art.py`) writes every generated image into `assets/art/`, and running it twice gives byte-identical files.
- [ ] A 16×16 tile atlas exists with: office floor, carpet, wall face, wall block, desk, desk with paper, open stairs, locked stairs.
- [ ] A player sheet exists: 4 facing directions × 3 frames (idle, walk 1, walk 2), 16×20 pixels each.
- [ ] Character sheets exist for the Clerk, Janitor, Archivist, Intern, Deputy Director and Spokesperson, each visibly different from the others and from the player in silhouette (hair or hat, clothes, body shape and props), not only in color.
- [ ] The bosses are bespoke 24×24 sprites with two idle frames that portray them as villains: the Deputy Director as an obese, sweating, scowling caricature of greed (cigar, gold, cash in his pocket), and the Spokesperson as a thin figure with bulging eyes, a huge fake grin and a megaphone.
- [ ] A `characters.json` file records each sheet's frame size, columns and row order so the game code does not hardcode them.
- [ ] A bitmap pixel font (PNG plus BMFont `.fnt`) covers printable ASCII (32-126) and imports into Godot as a usable font.
- [ ] A dev-only preview scene (`src/dev/art_preview.tscn`) shows the tiles, every character facing down, and sample text in the font.
- [ ] Project settings use nearest-neighbour texture filtering so pixels stay sharp.
- [ ] The existing game still launches and plays as before (this story changes no gameplay or layout).
- [ ] A retained screenshot of the preview scene is saved as evidence, with sign-off.

---

## Implementation Notes

- Pixel data lives in the generator as text grids with a named palette; all palettes are defined in one place so recolors are cheap.
- The generator uses only the Python standard library (no pip packages) and writes PNG itself.
- Generated PNGs are committed so the game never needs Python to run.

---

## Out of Scope

- Story 008: using the tiles and sprites in the floors.
- Story 009: the viewport size change and the UI theme (the font is only generated and previewed here).

---

## Files

- `tools/art/generate_art.py`
- `assets/art/` (tiles, 5 character sheets, 2 boss sheets, `characters.json`, font; generated, with Godot `.import` files)
- `src/dev/art_preview.tscn`, `src/dev/art_preview.gd`
- `project.godot` (nearest texture filter)

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Visual/Feel
**Required evidence**: a retained screenshot in `production/qa/evidence/` + sign-off in `production/qa/evidence/story-007-pixel-pipeline-evidence.md`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: `production/epics/pixel-style/story-008-floors-and-characters.md`

---

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 11/11 passing (none deferred)
**Deviations**: ADVISORY — the full-playthrough regression was last run after the texture-filter setting change and before the final character art and `characters.json`; those later changes touch no game code, but the playthrough was not re-run since. The art is generated pixel art in a simple style, not hand-drawn. Nothing in the game uses the art yet (stories 008 to 011). A texture loaded inside `_draw()` rendered as a white placeholder; sheets must be loaded once in `_ready()` (story 008 does this).
**Test Evidence**: waived at qa.level minimal; generator determinism checked by regenerating and comparing; retained screenshots and sign-off in production/qa/evidence/story-007-pixel-pipeline/ and production/qa/evidence/story-007-pixel-pipeline-evidence.md (sign-off approved by the user)
**Reviewed by**: self, no independent review
