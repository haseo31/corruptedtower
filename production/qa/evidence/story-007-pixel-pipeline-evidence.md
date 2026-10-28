# Evidence: Story 007 — Pixel art pipeline and pixel font

**Story**: `production/epics/pixel-style/story-007-pixel-pipeline.md`
**Date**: 2026-10-28
**Build**: Godot 4.7.2; `src/dev/art_preview.tscn` launched windowed at 2x (a dev-only scene).
**Method**: `python tools/art/generate_art.py` writes everything in `assets/art/` (run twice: all 11 files byte-identical). The preview scene was captured with Godot's movie recorder and the character rows enlarged 3x for inspection.

## Screenshots

| Image | What it shows |
|-------|---------------|
| `story-007-pixel-pipeline/01-art-preview.png` | The 8 tiles (floor, carpet, wall face, wall block, desk, desk with paper, open and locked stairs), the player in four directions plus walk frames, the cast, the two bosses with both idle frames, and sample text in the pixel font (lowercase, capitals, digits, punctuation, the menu arrow and continue arrow, descenders). |
| `story-007-pixel-pipeline/02-cast-zoomed.png` | The cast enlarged 3x, each in a front and a side view: the Player (teal cap), Clerk (slicked brown hair, glasses, tie, papers), Janitor (gray cap, moustache, overalls, mop), Archivist (gray bun, glasses, long skirt), Intern (spiky orange hair, hoodie, lanyard) and the two bosses. |
| `story-007-pixel-pipeline/03-bosses-zoomed.png` | The two bosses at 6x, both idle frames: the Deputy Director (obese, bald with a comb-over, sweating, scowling, cigar, gold buttons and buckle, cash in his pocket) and the Spokesperson (thin, slicked blond hair, bulging eyes, huge toothy grin, megaphone). |

## Regression

The full keyboard-only playthrough (floor 1, boss 1, floor 2, boss 2, ending, new run) was re-run after the project setting change and ended in the same state at every checkpoint.

## Notes

- A texture loaded inside `_draw()` came out as a white placeholder; textures must be loaded once in `_ready()`. The game code in story 008 does this.
- Placeholder art style: flat colors, 1 outline, simple shading; not hand-drawn pixel art.

## Sign-off

| Role | Approved | Notes |
|------|----------|-------|
| Developer / lead | [x] Approved | Approved by the user at /story-done on 2026-10-28. |
