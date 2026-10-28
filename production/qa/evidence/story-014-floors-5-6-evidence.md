# Story 014 evidence: Floors 5 and 6, harder bosses and a more thrilling climb

**Date**: 2026-10-28 | **Type**: Integration + Visual | **Tester**: self (no independent review)

## What was run

1. **Static data check** (all PASS): 18 evidence items, 18 fact-check challenges, 18 icons; every lie names evidence that exists; every NPC dialogue and character sheet resolves; every evidence item can be obtained (an NPC gives it or a desk holds it). Boss lie counts for floors 1 to 6 are 2, 3, 3, 4, 4, 5 and the Cover-up maximum is 3 for all. Floors 4, 5 and 6 each have a lie that needs several proofs (`lie_audit`, `lie_funds`, `lie_shaped`, `lie_clean`). Only floor 6's boss has `final: true`. The floor builder also checks that the spawn reaches every NPC and every desk clue on floors 5 and 6.
2. **Keyboard-only playthrough** (real game window, injected input actions only, no mouse, audio muted): starts on floor 4 with floors 1 to 3 already verified, then plays floor 4 (3 NPCs, desk, verify, expose the Director General with the new fourth lie that needs two proofs), floor 5 (3 NPCs, desk, verify, expose the Budget Secretary), floor 6 (3 NPCs, desk, verify, a wrong press, a repeated half proof that costs nothing, expose the Minister of Secrecy), and ends on the ending screen reading "Evidence verified: 18 of 18". It also checks that floors 5 and 6 and the final showdown start the `vault`, `archive` and `final_boss` music tracks. All 21 checks PASS.

## Screenshots (this folder)

| File | Shows |
|---|---|
| 01-floor-4-title-card | Floor title card (floor 4 of 6) with the tower progress strip |
| 02-floor-4-boss-intro, 03-floor-4-two-proofs-1of2, 04-floor-4-boss-won | Director General: intro line, "proof 1 of 2", win |
| 05-floor-4-stairs-open | Floor 4 stairs up now open |
| 06-floor-5-title-card, 07-floor-5-arrival | Floor 5 Budget Office: steel floor, gold carpet; title card; progress strip |
| 08-floor-5-accountant-gave-invoices, 09-floor-5-boss-room | Floor 5 NPCs and the Budget Secretary at the stairs |
| 10-floor-5-boss-intro, 11-floor-5-one-of-two, 12-floor-5-boss-won | Budget Secretary: intro, "proof 1 of 2", win |
| 13-floor-6-title-card, 14-floor-6-archive | Floor 6 Records Archive: violet stacks, red carpet, the Minister at the far end |
| 15-floor-6-final-boss-intro | Minister of Secrecy intro line |
| 16-floor-6-wrong-evidence | Wrong evidence: Cover-up 1 / 3 |
| 17-floor-6-one-of-two-then-repeat, 18-floor-6-two-of-three | Multi-proof lies: "proof 2 of 3" |
| 19-floor-6-final-boss-won | The Cover-up collapses |
| 20-ending-score | "Evidence verified: 18 of 18" |
| 21-how-to-play-showdowns | How to play page 5 with the new multi-proof line |

## Notes

- Found and fixed during the run: the tower progress strip drew over the showdown's Cover-up bar; it now sits under every panel.
- The ending screen still shows only the first two bosses and still restarts at floor 1; story 015 redoes it.
- The playthrough seeds floors 1 to 3 (evidence verified, bosses defeated) to keep the run short; floors 1 to 3 were played for real in story 013's run. Floors 3 and 4 have new fact-check texts (the tempting-source rewrite), which the seeded run does not exercise, but floor 4's three were played for real.
- Music: three new tracks (`vault`, `archive`, `final_boss`) were generated with ACE-Step 1.5; they were checked by loading and by the game choosing them, not by listening. Sign-off for how they sound is the user's.
- Sign-off for the Visual/UI evidence is the user's, on story-done.
