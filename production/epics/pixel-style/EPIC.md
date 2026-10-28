# Epic: Pokémon-style look (pixel-style)

> **Goal**: Make The Corrupted Tower look like a 16-bit top-down monster-catcher: tiled backgrounds, walking characters, a pixel font, a bordered text box, and a battle-style showdown. All art is drawn from code; no third-party assets.
> **Source**: `design/game-brief.md` (Art & audio direction), the user's request to look "like Pokémon's art style"
> **Engine**: Godot 4.7, GDScript, 2D
> **Boundary**: inspired by the genre only. No Nintendo sprites, tiles, fonts or other assets are copied or recreated.

## Order

Pipeline first (007), then the world (008), then the UI and view size together (009), then the showdown (010), then the remaining screens (011).

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 007 | Pixel art pipeline and pixel font | Visual/Feel | Ready | N/A |
| 008 | Floors and characters | Visual/Feel | Ready | N/A |
| 009 | UI theme, view size and dialogue box | UI | Ready | N/A |
| 010 | Battle-style showdown | UI | Ready | N/A |
| 011 | Remaining screens and player hints | UI | Ready | N/A |
