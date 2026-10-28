# Story 015 evidence: Title screen and three endings

**Date**: 2026-10-28 | **Type**: UI | **Tester**: self (no independent review)

The title screen, menus, settings and Quit-to-title were built and checked earlier (`story-015-title-menu-evidence.md`, screenshots in `story-015-title-menu/`). This note covers the endings.

## What was run

1. **Endings test** (headless logic plus a real game window, injected input only), 25 checks, all PASS:
   - `Endings.load_all()` reads `data/endings.json` (3 endings, best first); accuracy 100 and 90 give *The Tower Opens*, 89 and 60 give *Cracks in the Wall*, 59 and 0 give *The Cover-Up Lingers*; a missing file is refused.
   - First-try accuracy counting: no decisions counts as 100%; a wrong fact-check answer counts as wrong and the right one as right; in a showdown, wrong evidence counts as wrong, each counter counts as right, half of a two-proof lie counts once, and repeating that proof counts for nothing.
   - The save keeps the right and wrong counts, and an older save without them loads as zero.
   - Each of the three endings was shown on the real ending screen (the counts set to 95%, 74% and 33%) and chose the expected ending; pressing Enter on "Return to title" opens the title screen.
2. **Full keyboard playthrough** (same run as story 014): the real run reaches the ending screen with 27 right and 1 wrong decisions, 96%, and shows *The Tower Opens* with "Evidence verified: 18 of 18".

## Screenshots

`production/qa/evidence/story-015-endings/`:

| File | Shows |
|---|---|
| 01-ending-tower-opens | 95%: title, story, message, "Evidence verified: 18 of 18", the careful-play line, the two buttons, and the whole cast |
| 02-ending-cracks-in-the-wall | 74% (44 right, 15 wrong), 15 of 18 verified |
| 03-ending-cover-up-lingers | 33% (20 right, 40 wrong), 12 of 18 verified |
| 04-title-after-ending | The title screen after "Return to title" |

Also `story-014-floors-5-6/20-ending-score.png`: the ending reached by the real playthrough (96%).

## Deviation from the story text

The story chose the ending by the share of evidence verified (90% / 60%). That cannot work now: beating the six bosses requires at least 17 of the 18 items to be verified, so every finisher would be above 90% and two endings could never be reached. The endings are chosen by **first-try accuracy** instead (right choices over all fact-check answers and showdown evidence choices), with the same 90 and 60 thresholds, kept in `data/endings.json`. The ending screen still shows "Evidence verified: N of M". To go back to a verified-share rule, or move the thresholds, only the data file and `Endings.pick` input change.

## Notes

- Sign-off for the UI evidence is the user's, on story-done.
- The ending texts are first drafts, kept in data so they are easy to rewrite.
