class_name FactCheckChallenge
extends RefCounted
## One fact-check challenge for a piece of evidence: a claim, several sources or
## statements, and which one is the fake or unreliable one.

var evidence_id: String = ""
var claim: String = ""
var options: Array[String] = []
## Index into options of the fake or unreliable source.
var fake_index: int = -1
## Shown after a wrong answer, and after the right one, to explain why.
var explanation: String = ""


## Builds a challenge from a data entry. Returns null (and logs why) if it is invalid.
static func from_dict(data: Dictionary) -> FactCheckChallenge:
	var challenge := FactCheckChallenge.new()
	challenge.evidence_id = str(data.get("evidence_id", ""))
	challenge.claim = str(data.get("claim", ""))
	challenge.explanation = str(data.get("explanation", ""))
	challenge.fake_index = int(data.get("fake_index", -1))
	var option_entries: Variant = data.get("options", [])
	if option_entries is Array:
		for option: Variant in option_entries:
			challenge.options.append(str(option))
	if challenge.evidence_id.is_empty() or challenge.claim.is_empty() \
			or challenge.options.size() < 2 \
			or challenge.fake_index < 0 or challenge.fake_index >= challenge.options.size():
		push_error("FactCheckChallenge: needs an evidence_id, a claim, 2+ options and a valid fake_index")
		return null
	return challenge


## Loads every challenge from a JSON file ({"challenges": [...]}), keyed by evidence id.
## Returns an empty dictionary (and logs why) if the file is missing or invalid.
static func load_all(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("FactCheckChallenge: file not found: %s" % path)
		return {}
	var parsed: Variant = Tr.tree(JSON.parse_string(FileAccess.get_file_as_string(path)))
	if not (parsed is Dictionary) or not ((parsed as Dictionary).get("challenges") is Array):
		push_error("FactCheckChallenge: %s needs a 'challenges' list" % path)
		return {}
	var challenges: Dictionary = {}
	for entry: Variant in (parsed as Dictionary)["challenges"]:
		if entry is Dictionary:
			var challenge := from_dict(entry)
			if challenge != null:
				challenges[challenge.evidence_id] = challenge
	return challenges


## True if the option at this index is the fake or unreliable one.
func is_correct(option_index: int) -> bool:
	return option_index == fake_index
