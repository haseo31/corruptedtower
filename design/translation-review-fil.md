# Filipino translation: how to review it

The Filipino text in this game is a **first draft written by an AI assistant**. It has not been checked by a native speaker, a teacher or a lawyer. Please have a Filipino speaker review it before the game is shared widely, especially the case files (`lessons.json`), which state real facts about real cases.

## How it works

- The game is written in English. A translation is a table that maps each English sentence to its Filipino version: `data/translations/fil/*.json`, each file `{"strings": {"English sentence": "Filipino sentence"}}`.
- A sentence with no entry is shown in English, so nothing is ever blank.
- Players pick the language in **Settings, Wika**. It is saved with their other options.
- To fix a sentence, edit its Filipino value (the part on the right of the colon). Do not edit the English text on the left: it must match the game's text exactly, or the sentence will show in English.

## The files

| File | What it holds | Strings |
|---|---|---|
| `ui.json` | Menus, buttons, messages, the how-to-play guide | 104 |
| `story.json` | Evidence names and descriptions, bosses, floors, character names, endings | 172 |
| `dialogues.json` | Everything the characters say | 199 |
| `factchecks.json` | The fact-check questions, sources and explanations | 105 |
| `lessons.json` | The six case files and the closing guide | 95 |
| `sources.json` | The source lines under each real case | 10 |

## Things to check

1. **Meaning and facts.** The case files must say what the English says, no more and no less. Names of laws, courts and agencies (COA, COMELEC, Ombudsman, Sandiganbayan, PDAF) are kept in English on purpose, because that is how they are known.
2. **Register.** The text uses plain, friendly Filipino ("mo", "ka"). Change it if you prefer a more formal or more street-level voice.
3. **Taglish.** Some modern words stay in English (fact-check, bot, e-wallet, steel bar, flood wall, invoice, audit). Replace them if you have a better everyday word.
4. **Length.** The game's pixel font draws plain ASCII only: no accents or special letters. Keep text plain, and keep sentences about as long as the English, so they fit the boxes.
5. **Placeholders.** Keep `%d` and `%s` exactly where they are (for example "Pahina %d ng %d"). The game fills them in.
6. **Quiz answers.** In the fact-check questions, only the wording is translated. The right answer never moves.

## Names written in English on purpose

The game's title ("The Corrupted Tower"), file ids such as `ledger_page`, and the titles of real documents inside source lines.

## After editing

Run the game, choose Wika, and look at the screen you changed. The test in `production/qa/evidence/story-020-filipino-evidence.md` shows how it was checked: every sentence in the data files has a translation, and the longest pages fit.
