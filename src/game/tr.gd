class_name Tr
extends RefCounted
## Text in the player's language. The game is written in English; a translation is a table that
## maps an English sentence to its translation (data/translations/<language>/*.json, each file
## {"strings": {"English": "Translation"}}). A sentence with no entry stays in English, so the
## game never shows a blank. Data files are translated as they are loaded (tree()), and screens
## translate their fixed labels (apply()) and the sentences they build (t()).

const DIR: String = "res://data/translations/"
## Language id and the name shown in the Settings screen (written in that language).
const LANGUAGES: Array = [["en", "English"], ["fil", "Filipino"]]
## Data keys whose values are never text to translate (ids, paths and rows of tiles).
const SKIP_KEYS: Array = ["id", "next", "sprite", "scene", "boss", "dialogue", "evidence_id", "boss_id", "flag", "rows",
		"requires_flag", "hide_if_flag", "set_flags", "counter_evidence_ids", "counter_all", "node", "evidence", "theme",
		"music", "start", "spawn", "objective_boss", "give_evidence", "_note", "type"]

static var language: String = "en"
static var _table: Dictionary = {}


## Switches language and loads its table (English needs none).
static func set_language(id: String) -> void:
	language = id
	_table = {}
	if id == "en":
		return
	var dir := DirAccess.open(DIR + id)
	if dir == null:
		push_warning("Tr: no translation folder for '%s'" % id)
		return
	for file_name in dir.get_files():
		if file_name.ends_with(".json"):
			var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("%s%s/%s" % [DIR, id, file_name]))
			if parsed is Dictionary and parsed.get("strings") is Dictionary:
				_table.merge(parsed["strings"], true)


## The translation of one sentence, or the sentence itself if there is none.
static func t(text: String) -> String:
	if language == "en" or text.is_empty():
		return text
	return str(_table.get(text, text))


## True if this sentence has a translation in the current language.
static func has(text: String) -> bool:
	return language == "en" or _table.has(text)


## A copy of parsed data with every sentence translated. Values under SKIP_KEYS are left alone.
static func tree(data: Variant, key: String = "") -> Variant:
	if language == "en":
		return data
	if data is String:
		return data if key in SKIP_KEYS else t(data)
	if data is Array:
		var items: Array = []
		for item: Variant in data:
			items.append(tree(item, key))
		return items
	if data is Dictionary:
		var copy: Dictionary = {}
		for k: Variant in data:
			copy[k] = tree(data[k], str(k))
		return copy
	return data


## Translates the fixed text of a screen: every label and button under this node.
static func apply(node: Node) -> void:
	if language == "en":
		return
	if node is Label or node is Button:
		node.text = t(node.text)
	for child in node.get_children():
		apply(child)


## The name of a language id, as shown in Settings.
static func language_name(id: String) -> String:
	for entry: Array in LANGUAGES:
		if entry[0] == id:
			return entry[1]
	return id
