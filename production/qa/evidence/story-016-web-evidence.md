# Story 016 evidence: Web export

**Date**: 2026-10-28 | **Type**: Config/Data | **Tester**: self (no independent review)

## What was run

1. **Build**: `bash tools/build_web.sh` produces `build/web/` (47 MB: the engine `index.wasm` 39 MB, the game `index.pck` 9 MB with all art, data, music and sound effects, plus the loader files). It is a single-thread build, so it needs no special server headers. `build/` is not committed.
2. **Served locally** with `python -m http.server 8000 --directory build/web` and opened in the built-in browser.
3. **Played in the browser** (keyboard events held for a realistic time): title screen; PLAY; the floor 1 title card and map; walking; the fund clerk's dialogue and the choice "What will you do with my name?"; the evidence screen; a fact-check that verified the ledger; the pause menu and **Save** ("Game saved."); then the page was **reloaded** and the title now showed **CONTINUE**; Continue restored floor 1 with the ledger still marked Verified.
4. **Console**: only four WebGL warnings at start-up ("Framebuffer is incomplete: Attachment has zero size", while the canvas is first sized); no errors during the run.

## Screenshots (`story-016-web/`)

| File | Shows |
|---|---|
| 01-title-in-browser | The title screen in the browser |
| 02-floor-1-in-browser | Floor 1 |
| 03-dialogue-in-browser, 04-choice-in-browser | The clerk's dialogue and the choice about their name |
| 05-fact-check-verified-in-browser | A fact-check verified |
| 06-game-saved-in-browser | Pause menu, "Game saved." |
| 07-continue-after-reload | After a page reload: CONTINUE is offered |
| 08-state-restored-after-continue | Continue restored the game: ledger still Verified |

## Not verified

- **A full run from the title to the ending in the browser** (acceptance criterion 4) was not played; it takes about twenty minutes. The same code was played from floor 4 to the ending natively. Someone should play one full run in the browser before release.
- **Sound** in the browser: the audio files are in the build, but I cannot hear them.
- Very short key taps from my test tool (under one frame) did not register; a real keyboard holds keys much longer. Touch screens are not supported (out of scope).

## Notes

- The browser keeps saves in the browser's own storage for this address: a different address, a private window or cleared site data starts with no save.
- Sign-off for the evidence is the user's, on story-done.
