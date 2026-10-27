# Game Brief: The Corrupted Tower

**One-sentence pitch:** Climb a corrupt government tower in a top-down Pokémon-style adventure, collect real evidence instead of monsters, and use it to expose each floor's Corruption Boss in turn-based showdowns.

## Core loop
- Explore a floor, talk to NPCs, and find documents or clues.
- Verify each clue in a short fact-check challenge, and add the verified ones to your evidence inventory.
- Pick the right evidence to use in a boss's turn-based showdown.
- Beat the boss, unlock the next floor, and see how much you exposed.

## Player goal & fail state — what "working" looks like
- **Goal:** reach the top floor by exposing every boss.
- **Fail state:** a boss's "Cover-up" meter fills if you present wrong or unverified evidence, and you restart that showdown (evidence you already collected is kept).
- **Ending:** it depends on how much verified evidence you gathered.

## MVP — what must exist to be the game
1. A top-down walkable floor (grid movement, collisions, floor transitions).
2. NPC dialogue and interviews that can reveal clues.
3. An evidence inventory (collect, view, verified or unverified).
4. One fact-check mini-game type (for example, spot the fake claim or source).
5. A turn-based boss showdown where evidence counters the boss's lies.
6. Two floors, Bribery and Disinformation, each with a boss, and an ending screen driven by evidence count.

## Out of scope — not building this
- Real-time combat, multiplayer, and a save system beyond a basic checkpoint.
- Floors beyond the first two (vote-buying, nepotism, public funds and transparency come later).
- Multiple endings (the MVP has a single score-based ending screen).
- Voice acting and a custom map editor.

## Build order
1. The boss showdown: evidence vs lies, turn-based. This is the riskiest and least proven part, and it needs to be fun.
2. Evidence inventory and the fact-check mini-game.
3. Floor exploration, NPC dialogue and interviews.
4. A second floor, then the ending screen.

---
**Who it's for / what they feel:** Senior high school and college students and first-time voters, who should feel like a sharp investigator and leave better at spotting misinformation.

**Art & audio direction:** Pixel art with a gritty government-office look that gets more corrupted as you climb, with chiptune audio.

**Reference game:** Pokémon (Gen 1–3). The MVP keeps the top-down exploration and turn-based showdowns, with evidence as your "moves" and no catching or leveling.
