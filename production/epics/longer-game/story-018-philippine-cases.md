# Story 018: Re-theme the tower around real Philippine corruption cases

> **Epic**: longer-game
> **Status**: Complete
> **Layer**: Content
> **Type**: Config/Data
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

## Context

**Requirement**: The user asked that the bosses and evidence gathering be about corruption scandals in the Philippines, highlighting the latest administration's, including flood control. The approach chosen: composite characters anchored in real, documented cases; several administrations covered, with the latest given the most weight; no real person named.

---

## Acceptance Criteria

- [x] The six floors are built on documented cases: the pork barrel (PDAF) scam, election disinformation, vote-buying, nepotism and political dynasties, flood control ghost projects (current administration), and budget insertions with hidden records.
- [x] Evidence, fact-checks, dialogue, boss lies and floor text on floors 1, 5 and 6 match those cases; ids are unchanged so saves and code keep working.
- [x] No real person is named; bosses are composite roles.
- [x] Each case file has a "real case" page and, where there is more to say, a second page ("what happened next" or "how common it is"), with named sources.
- [x] The closing guide adds "Three cases, three administrations" and "What the cases share" pages, and says accused people are presumed innocent.
- [x] `design/lessons-sources.md` lists every new fact, its sources, how it was checked and what to re-check.
- [x] A recorded keyboard-only run reads every case file and the closing guide.

---

## Out of Scope

- Naming real people, even those charged; satirical portraits of real politicians.
- A local expert's fact review and a Filipino translation (recommended next).

---

## Files

- `data/lessons.json`, `data/evidence/evidence.json`, `data/factchecks/factchecks.json`, `data/dialogue/dialogues.json`, `data/bosses/`, `data/floors/floor_1.json`, `floor_5.json`
- `src/game/lessons.gd` (optional second real-case page), `design/lessons-sources.md`

## Test Evidence

**Story Type**: Config/Data
**Status**: [x] Playtest record `production/qa/evidence/story-017-learning-layer-evidence.md` (updated) with screenshots in `production/qa/evidence/story-017-learning-layer/`

---

## Dependencies

- Depends on: `production/epics/longer-game/story-017-learning-layer.md`

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 7/7 passing
**Deviations**: The facts come from web searches (news and law-site summaries); the 2025 to 2026 flood control cases are still moving, so the file lists what to re-check. Floors 2 to 4 keep their earlier look; only their case files changed (floor 4 gained a second page).
**Reviewed by**: self, no independent review
