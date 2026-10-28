# Story 019 evidence: Side characters and choices with consequences

**Date**: 2026-10-28 | **Type**: Integration | **Tester**: self (no independent review)

## What was run

1. **Logic test** (headless, 25 checks, all PASS): 21 evidence items; each bonus item has a fact-check and an icon; both new character sheets load; the clerk gives the ledger and asks about their name, "keep it out" and "use it" set different flags; taking the envelope sets its flag and counts one wrong choice, it is not offered twice, and refusing counts one right choice; the whistleblower gives nothing to a stranger or to someone who took the envelope and gives the folder to someone who refused; the anonymous source gives the leaked email once; floor 4 shows one more character only after the clerk's name was protected (4 vs 5); the leaked email counters the whole audit lie alone and the long way (two proofs) still works; saves keep the flags and an older save loads with none; the ending notes match the flags.
2. **Keyboard-only playthrough** (real window, injected input only): floor 1 the clerk (protect the name), floor 2 the anonymous source, floor 3 the envelope (refuse), floor 4 the former clerk, floor 5 the whistleblower; the four collected items are verified; the Chief Engineer is exposed with the witness statement as a shortcut; the ending screen notes both choices. All checks PASS.
3. **Regression**: the full floor 4 to 6 keyboard run from story 017 still passes (35 checks); the score line now reads "Evidence verified: 18 of 21".

## Screenshots (`story-019-choices/`)

| File | Shows |
|---|---|
| L-clerk-promise, L-clerk-promise-2 | The Fund Clerk's choices, then "What will you do with my name?" with the new ledger |
| L-floor2-anonymous-source, L-source-choices | The anonymous source on floor 2 |
| L-envelope-choice | The campaign worker's offer on floor 3 |
| L-floor4-former-clerk, L-former-clerk | The former clerk, who is there only because their name was protected |
| L-whistleblower, L-whistleblower-2 | The whistleblower, who trusts someone who refused the envelope |
| L-boss-intro, L-shortcut-won | The Chief Engineer, and the witness statement exposing the funds lie alone |
| L-ending-notes | The ending lines about the choices |

## Notes

- The shortcut items only apply to each boss's last lie, so a player who finds them skips the hardest step, not the fight.
- A player who skips the campaign worker or takes the envelope can still go back down a floor and meet the whistleblower again, but only the refusal opens the folder.
- Sign-off for the UI evidence is the user's, on story-done.
