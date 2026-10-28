# Story 017 evidence: Learning layer

**Date**: 2026-10-28 | **Type**: UI | **Tester**: self (no independent review)

## What was run

1. **Data test** (headless, 22 checks, all PASS): the lessons file loads; six cases in floor order; every floor's boss has a case file; each case builds 5 pages with a title and body, the Philippines page names its sources, and every page is under 420 characters; the closing guide has 4 pages; a missing file is refused. A separate script check confirmed every character in the lessons and endings is one the pixel font can draw.
2. **Keyboard-only playthrough** (real window, injected input only), 35 checks, all PASS: from floor 4 to the ending, the case file opens after the Director General, the Budget Secretary and the Minister of Secrecy and is read to the last page; the Tower Journal opens from the pause menu showing four unlocked cases and two locked; choosing an entry opens its case file; Esc returns to the journal and then to the game; on the ending screen "What can I do?" opens the 4-page closing guide, which closes on the last page and returns focus to the button.

The two "get_node on null" messages in the log come from the test script touching the scene while it changes; they are not game errors.

## Screenshots (`story-017-learning-layer/`)

| File | Shows |
|---|---|
| L-floor4-page-1 to 5 | All five pages of case file 4 (Jobs for family): trick, real facts with sources, made-up story, what you can do, words to know |
| L-floor5-page-2, page-3 | Case file 5 (Ghost projects): the PDAF ruling and the 2025 flood control findings; the story |
| L-floor6-page-2, page-5 | Case file 6 (Hidden records): the right to information and EO 2; words to know |
| L-journal, L-journal-case | The Tower Journal with four cases unlocked and two locked; an entry opened |
| L-ending-with-action-button | The ending screen with the new "What can I do?" button |
| L-finale-page-1 to 4 | The closing guide: the real numbers, four habits, where to report, how a complaint works |
| L-how-to-play-page-6 | The how-to-play guide mentioning the Tower Journal |

## Notes

- The real-world facts and their sources are in `design/lessons-sources.md`, with the items that should be re-checked by a person before the game is shared widely.
- The case file opens over the floor without dimming it; it is readable but a dim layer behind it would look more finished.
- Sign-off for the UI evidence is the user's, on story-done.
