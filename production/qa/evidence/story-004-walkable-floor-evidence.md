# Evidence: Story 004 — Walkable floor

**Story**: `production/epics/the-corrupted-tower/story-004-walkable-floor.md`
**Date**: 2026-10-28
**Build**: Godot 4.7.2, project launched windowed at 1152×648 (the project's default window)
**Method**: the project's main scene was launched, then a scripted run drove the real game with synthetic keyboard input only (`move_right`, `move_up`, `move_left`, the same actions the arrow keys, WASD and D-pad map to). The script is a throwaway and is not in the repo.

## Screenshots

| Image | What it shows |
|-------|---------------|
| `00-launch-main-scene.png` | Plain launch of the project with no script: the main scene opens on Floor 1: Lobby with the player on the grid (AC7). The movie recorder scales this frame, so it looks smaller than the others. |
| `01-start.png` | Floor 1 at the start: player at cell (2, 12), floor name top-left, camera centre at (576, 400), clamped to the left floor edge. |
| `02-walking-camera-follows.png` | Player at cell (30, 12); camera centre at (704, 400), so the view has scrolled and desks on the left are cropped; the right-hand wall and teal transition tile are in view (AC6). |
| `03-blocked-by-desk-facing-up.png` | Player at cell (12, 12) after pressing up into the desk row: it did not move (not moving: true) and its facing marker points up (AC3, AC4). |
| `04-floor-2.png` | After stepping on the teal transition tile at (38, 12): Floor 2: Records Room, player arrived at (2, 12) beside floor 2's transition tile (AC5). |
| `05-back-on-floor-1.png` | After stepping on floor 2's transition tile: back on Floor 1 at (37, 12), beside floor 1's transition tile (AC5). |

## Run log

```
camera centre at start (576, 400)
blocked at cell (12, 12) facing (0, -1) moving false
camera centre at cell (30, 12) (704, 400)
arrived on floor 2 at cell (2, 12)
back on floor 1 at cell (37, 12)
```

## Not shown by a still (feel, deferred to a playtest)

- Whether the 0.15 s step and the camera smoothing feel right.
- The idle bob while standing still (AC4's idle state is visible only in motion).

## Sign-off

| Role | Approved | Notes |
|------|----------|-------|
| Developer / lead | [x] Approved | Approved by the user at /story-done on 2026-10-28. Placeholder art only (flat shapes); feel and idle bob deferred to a live playtest. |
