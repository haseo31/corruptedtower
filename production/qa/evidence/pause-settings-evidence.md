# Evidence: Settings in the pause menu (volume while playing)

**Date**: 2026-10-28 | **Type**: UI | **Tester**: self (no independent review)

The user asked to be able to change the volume while playing. Before this, Settings could only be opened from the title screen.

## What changed

The pause menu (Esc) has a new **Settings** entry. It opens the same Settings screen as the title (language, window, music volume, effects volume, text speed, reduce motion, reset). Esc goes back to the pause menu, and Esc again returns to the game. Every change is applied and saved at once. The Filipino label is "Mga setting".

## What was run (real window, injected keys, 13 checks, all PASS)

Esc opens the pause menu; it has a Settings entry; Settings opens over the game and the player cannot walk meanwhile; Left on the music row turns the music down (7 to 5) and the real music bus gets quieter; Right turns it up; the effects volume changes too; the change is saved to the settings file at once; Esc returns to the pause menu; Esc again returns to the game and the player can walk.

Screenshot: `story-016-pause-settings/L-pause-settings.png`.

## Notes

- Changing the language from inside the game takes effect on the next screen the game loads; the screen already open stays as it was.
- In the browser version the window-size rows do nothing (itch.io's own fullscreen button is used); the volume rows work.
