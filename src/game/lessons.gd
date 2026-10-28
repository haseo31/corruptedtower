class_name Lessons
extends RefCounted
## The case files that teach what each boss stood for, read from data/lessons.json. A case
## file has a named trick to spot, what the law and the news say in the Philippines (with
## sources), a made-up story of how it hurts people, what the player can do, and a few
## words to know. This class loads and checks the data and turns it into pages to show;
## it holds no scene or UI.

const PATH: String = "res://data/lessons.json"


## Reads and checks the lessons file. Returns {"cases": {boss_id: case}, "order": [boss ids in
## the order of the file], "finale": {"heading", "pages"}}, or an empty dictionary (and logs
## why) if the file is missing or invalid.
static func load_json(path: String = PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Lessons: file not found: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary) or not (parsed.get("lessons") is Array):
		push_error("Lessons: %s needs a 'lessons' list" % path)
		return {}
	var cases: Dictionary = {}
	var order: Array[String] = []
	for entry: Variant in parsed["lessons"]:
		if not _is_valid_case(entry):
			push_error("Lessons: a case needs boss_id, title, trick, real_world, story, action and words")
			return {}
		cases[str(entry["boss_id"])] = entry
		order.append(str(entry["boss_id"]))
	var finale: Variant = parsed.get("finale", {})
	if not (finale is Dictionary) or not (finale.get("pages", []) is Array):
		push_error("Lessons: 'finale' needs a list of pages")
		return {}
	return {"cases": cases, "order": order, "finale": finale}


## The pages of one case file: [{"title", "body", "footer"}]. Five pages, or six when the real
## case has a second page ("more" in the data).
static func case_pages(case: Dictionary) -> Array:
	var words: Array[String] = []
	for word: Dictionary in case["words"]:
		words.append("%s: %s" % [word["term"], word["meaning"]])
	var pages: Array = [
		{"title": "The trick: %s" % case["trick"]["name"], "body": case["trick"]["text"], "footer": ""},
		{"title": "The real case (Philippines)", "body": case["real_world"]["text"],
			"footer": "Sources: %s" % case["real_world"].get("sources", "")},
	]
	# An optional second real-world page: what happened next, or how common it is.
	var more: String = str(case["real_world"].get("more", ""))
	if not more.is_empty():
		pages.append({"title": str(case["real_world"].get("more_title", "What happened next (real)")),
			"body": more, "footer": "Sources: %s" % case["real_world"].get("more_sources", "")})
	pages.append_array([
		{"title": "How it hurts people (a made-up story)", "body": case["story"]["text"], "footer": ""},
		{"title": "What you can do", "body": case["action"], "footer": ""},
		{"title": "Words to know", "body": "\n".join(words), "footer": ""},
	])
	return pages


## The pages of the closing "After the tower" guide: [{"title", "body", "footer"}].
static func finale_pages(finale: Dictionary) -> Array:
	var pages: Array = []
	for page: Dictionary in finale.get("pages", []):
		pages.append({"title": str(page.get("title", "")), "body": str(page.get("body", "")),
			"footer": str(page.get("footer", ""))})
	return pages


static func _is_valid_case(entry: Variant) -> bool:
	if not (entry is Dictionary):
		return false
	for key: String in ["boss_id", "title", "action"]:
		if str(entry.get(key, "")).is_empty():
			return false
	for key: String in ["trick", "real_world", "story"]:
		if not (entry.get(key) is Dictionary) or str(entry[key].get("text", "")).is_empty():
			return false
	if str(entry["trick"].get("name", "")).is_empty() or not (entry.get("words") is Array):
		return false
	for word: Variant in entry["words"]:
		if not (word is Dictionary) or str(word.get("term", "")).is_empty() or str(word.get("meaning", "")).is_empty():
			return false
	return true
