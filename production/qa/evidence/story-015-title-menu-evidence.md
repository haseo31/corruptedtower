# Main menu (story 015, part 1) evidence

**Date**: 2026-10-28 | **Type**: UI | **Tester**: self (no independent review)

Built: animated title screen (`src/ui/title_screen.*`, `title_backdrop.gd`), HOW TO PLAY guide (`how_to_play_panel.gd`), SETTINGS (`settings_panel.gd`, `src/game/game_settings.gd`, saved to `user://settings.json`). The game now opens on the title; the pause menu's Quit goes back to it.

## Keyboard-only run (real game, injected input actions, scratch save/settings files)

- Opens focused on PLAY; CONTINUE is hidden without a save and shown and focused with one; Continue loads floor 1 at the saved tile with the saved evidence.
- HOW TO PLAY: 6 pages, Left/Right turn, Esc returns focus to HOW TO PLAY.
- SETTINGS: window size 480x320 chosen, music 4, effects 9, text speed Fast (dialogue speed 90), reduce motion On; settings file written.
- PLAY starts floor 1; Esc then "Quit to title" returns to the title. EXIT quits the game (seen when a test step landed on it).

## Screenshots (story-015-title-menu/)
01 title (no save), 02 menu focus, 03-05 guide pages 1/3/6, 06 settings, 07 settings changed, 08 pause menu, 09 title with CONTINUE.

## Not done / notes
- The three endings and the ending's "return to title" button remain in story 015.
- No audio exists yet, so the volume sliders set the Music and SFX buses (created at start-up) but nothing plays on them.
- Fullscreen was not toggled in this run (headless-safe code path only); checked by reading, not by eye.
