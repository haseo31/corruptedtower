class_name BossData
extends RefCounted
## Data for one Corruption Boss: the lies it tells and how its Cover-up meter behaves.
## Built from a data file so boss values never live in code.


## One lie a boss tells, and the evidence ids that counter it.
class Lie extends RefCounted:
	var id: String = ""
	var text: String = ""
	var counter_evidence_ids: Array[String] = []


var id: String = ""
var display_name: String = ""
## The Cover-up meter value at which the player loses the showdown.
var cover_up_max: int = 3
## How much the Cover-up meter rises when wrong or unverified evidence is presented.
var wrong_evidence_penalty: int = 1
## The lies in the order the player must counter them.
var lies: Array[Lie] = []


## Builds a boss from a parsed data dictionary. Returns null (and logs why) if the data is invalid.
static func from_dict(data: Dictionary) -> BossData:
	var boss := BossData.new()
	boss.id = str(data.get("id", ""))
	boss.display_name = str(data.get("display_name", ""))
	boss.cover_up_max = int(data.get("cover_up_max", 0))
	boss.wrong_evidence_penalty = int(data.get("wrong_evidence_penalty", 0))
	if boss.id.is_empty() or boss.cover_up_max < 1 or boss.wrong_evidence_penalty < 1:
		push_error("BossData: needs an id, cover_up_max >= 1 and wrong_evidence_penalty >= 1")
		return null
	var lie_entries: Variant = data.get("lies", [])
	if not (lie_entries is Array) or (lie_entries as Array).is_empty():
		push_error("BossData '%s': needs at least one lie" % boss.id)
		return null
	for entry: Variant in lie_entries:
		if not (entry is Dictionary):
			push_error("BossData '%s': each lie must be an object" % boss.id)
			return null
		var lie := Lie.new()
		lie.id = str(entry.get("id", ""))
		lie.text = str(entry.get("text", ""))
		for evidence_id: Variant in entry.get("counter_evidence_ids", []):
			lie.counter_evidence_ids.append(str(evidence_id))
		if lie.id.is_empty() or lie.counter_evidence_ids.is_empty():
			push_error("BossData '%s': each lie needs an id and counter evidence" % boss.id)
			return null
		boss.lies.append(lie)
	return boss


## Loads a boss from a JSON file. Returns null (and logs why) if the file is missing or invalid.
static func load_json(path: String) -> BossData:
	if not FileAccess.file_exists(path):
		push_error("BossData: file not found: %s" % path)
		return null
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary):
		push_error("BossData: %s is not a JSON object" % path)
		return null
	return from_dict(parsed)
