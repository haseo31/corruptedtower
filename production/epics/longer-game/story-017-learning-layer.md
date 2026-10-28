# Story 017: Learning layer (case files, Tower Journal, closing guide)

> **Epic**: longer-game
> **Status**: Complete
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

## Context

**GDD**: `design/game-brief.md`
**Requirement**: The user asked that, after finishing the game, players know how corruption in the Philippines affects people's lives and are more aware of it.
**ADR Governing Implementation**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: LOW (text panels)

---

## Acceptance Criteria

- [x] After each boss is exposed, a case file opens with 5 pages: the named trick to spot, what is true in the Philippines (with named sources), a made-up story of how it hurts people, what the player can do, and words to know. Esc or the last page closes it.
- [x] Each of the six bosses has a case file, and all text is in `data/lessons.json`, not code.
- [x] The real-world page states only facts with a source and year, and `design/lessons-sources.md` records where each came from and what should be re-checked.
- [x] The pause menu has a Tower Journal listing the case files: unlocked for exposed bosses, locked for the rest; choosing one reopens it.
- [x] The ending screen has a "What can I do?" guide (4 pages: the real numbers, four habits, where to report, how a complaint works).
- [x] The how-to-play guide mentions the journal.
- [x] Everything works with the keyboard only, and a recorded run reads every case file and the closing guide.

---

## Out of Scope

- A Filipino (Tagalog) translation, and an independent fact review by a local expert (both recommended next).
- Real names of living people as wrongdoers.

---

## Files

- `data/lessons.json`, `design/lessons-sources.md`
- `src/game/lessons.gd`, `src/ui/case_file_panel.gd`, `src/ui/journal_panel.gd`
- `src/world/floor_scene.gd`, `src/ui/pause_menu.gd/.tscn`, `src/ui/ending_screen.gd/.tscn`, `src/ui/how_to_play_panel.gd`

## Test Evidence

**Story Type**: UI
**Required evidence**: a retained screenshot of each screen touched, in `production/qa/evidence/`

**Status**: [x] Created: `production/qa/evidence/story-017-learning-layer-evidence.md`, screenshots in `production/qa/evidence/story-017-learning-layer/`

---

## Dependencies

- Depends on: `production/epics/longer-game/story-015-title-and-endings.md`

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 7/7 passing
**Deviations**: Not in the original epic; added at the user's request. The facts were checked by web search only, mostly through news and law-site summaries; the file lists what should be re-checked by a person.
**Test Evidence**: waived at qa.level minimal; playtest record and screenshots as above
**Reviewed by**: self, no independent review
