class_name GameSession
extends RefCounted
## State that must survive changing floors: the player's evidence inventory, the
## bosses already defeated, and the loaded dialogues and fact-check challenges. Held
## in static variables because a scene change frees every node; reset() starts a new run.

const EVIDENCE_PATH: String = "res://data/evidence/evidence.json"
const DIALOGUE_PATH: String = "res://data/dialogue/dialogues.json"
const FACTCHECK_PATH: String = "res://data/factchecks/factchecks.json"

static var _inventory: EvidenceInventory
static var _dialogues: Dictionary = {}
static var _challenges: Dictionary = {}
static var _defeated_bosses: Array[String] = []
## How many fact-check answers and showdown evidence choices were right or wrong this run.
static var good_choices: int = 0
static var wrong_choices: int = 0


## The player's evidence inventory, created on first use.
static func inventory() -> EvidenceInventory:
	if _inventory == null:
		_inventory = EvidenceInventory.new(EvidenceInventory.load_catalog(EVIDENCE_PATH))
	return _inventory


## Every dialogue by id, loaded on first use.
static func dialogues() -> Dictionary:
	if _dialogues.is_empty():
		_dialogues = DialogueRunner.load_all(DIALOGUE_PATH)
	return _dialogues


## Every fact-check challenge by evidence id, loaded on first use.
static func challenges() -> Dictionary:
	if _challenges.is_empty():
		_challenges = FactCheckChallenge.load_all(FACTCHECK_PATH)
	return _challenges


## Records that a boss has been exposed.
static func mark_defeated(boss_id: String) -> void:
	if not _defeated_bosses.has(boss_id):
		_defeated_bosses.append(boss_id)


## True if this boss has been exposed this run.
static func is_defeated(boss_id: String) -> bool:
	return _defeated_bosses.has(boss_id)


## The ids of the bosses exposed this run.
static func defeated_bosses() -> Array[String]:
	return _defeated_bosses.duplicate()


## Notes one decision: a right or a wrong fact-check answer or piece of showdown evidence.
static func record_choice(correct: bool) -> void:
	if correct:
		good_choices += 1
	else:
		wrong_choices += 1


## The share of decisions that were right, 0 to 100. A run with no decisions counts as 100.
static func accuracy_percent() -> int:
	var total := good_choices + wrong_choices
	return 100 if total == 0 else good_choices * 100 / total


## Starts a fresh run and puts back saved state: the evidence entries ({"id", "verified"}),
## the defeated boss ids and the right and wrong decision counts.
static func restore(evidence: Array, defeated: Array, good: int = 0, wrong: int = 0) -> void:
	reset()
	good_choices = good
	wrong_choices = wrong
	var inv := inventory()
	for entry: Dictionary in evidence:
		inv.collect(entry["id"])
		if entry["verified"]:
			inv.verify(entry["id"])
	for boss_id: String in defeated:
		mark_defeated(boss_id)


## Forgets everything, as at the start of a new run.
static func reset() -> void:
	_inventory = null
	_dialogues = {}
	_challenges = {}
	_defeated_bosses = []
	good_choices = 0
	wrong_choices = 0
