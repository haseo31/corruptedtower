class_name Endings
extends RefCounted
## The game's endings, read from a data file. Each ending has the lowest first-try
## accuracy (0 to 100) that earns it, a title, a story text and a short civic message.
## pick() chooses the one the player earned; it holds no scene or UI so it can be tested alone.

const PATH: String = "res://data/endings.json"


## Reads and checks the endings file. Returns them best first, or an empty array (and logs
## why) if the file is missing or invalid. A valid file has one ending with min_accuracy 0,
## so every player gets an ending.
static func load_all(path: String = PATH) -> Array:
	if not FileAccess.file_exists(path):
		push_error("Endings: file not found: %s" % path)
		return []
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary) or not (parsed.get("endings") is Array):
		push_error("Endings: %s needs an 'endings' list" % path)
		return []
	var endings: Array = []
	var has_floor := false
	for entry: Variant in parsed["endings"]:
		if not (entry is Dictionary) or str(entry.get("id", "")).is_empty() or str(entry.get("title", "")).is_empty() \
				or not (entry.get("min_accuracy") is float):
			push_error("Endings: each ending needs an id, a title and a min_accuracy")
			return []
		has_floor = has_floor or int(entry["min_accuracy"]) <= 0
		endings.append({
			"id": str(entry["id"]),
			"min_accuracy": int(entry["min_accuracy"]),
			"title": str(entry["title"]),
			"text": str(entry.get("text", "")),
			"message": str(entry.get("message", "")),
		})
	if not has_floor:
		push_error("Endings: one ending needs min_accuracy 0")
		return []
	endings.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["min_accuracy"] > b["min_accuracy"])
	return endings


## The ending earned with this accuracy (0 to 100): the best one whose minimum is met.
static func pick(endings: Array, accuracy_percent: int) -> Dictionary:
	for ending: Dictionary in endings:
		if accuracy_percent >= int(ending["min_accuracy"]):
			return ending
	return {}
