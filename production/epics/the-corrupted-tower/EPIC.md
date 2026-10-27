# Epic: The Corrupted Tower (MVP)

> **Goal**: Climb a corrupt government tower in a top-down Pokémon-style adventure, collect real evidence instead of monsters, and use it to expose each floor's Corruption Boss in turn-based showdowns.
> **Source**: `design/game-brief.md` (no GDD or ADRs at the `minimal` workflow)
> **Engine**: Godot 4.7, GDScript, 2D

## Scope

The brief's MVP list: walkable floor, NPC interviews, evidence inventory, one fact-check mini-game, turn-based boss showdown, two floors (Bribery, Disinformation) and an evidence-count ending.

## Order

The brief's build order: boss showdown first (riskiest), then inventory and fact-check, then exploration and NPCs, then the second floor and ending.

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Boss showdown | Logic | Ready | N/A |
| 002 | Evidence inventory | Logic | Ready | N/A |
| 003 | Fact-check mini-game | Integration | Ready | N/A |
| 004 | Walkable floor | Visual/Feel | Ready | N/A |
| 005 | NPC dialogue and interviews | Integration | Ready | N/A |
| 006 | Two floors and ending screen | Integration | Ready | N/A |
