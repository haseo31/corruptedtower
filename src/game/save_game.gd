class_name SaveGame
extends RefCounted
## Saving and loading the player's progress as one JSON file under user://. The file holds a
## version number, the floor and tile the player stands on, the evidence collected (with
## whether each is verified) and the bosses exposed. read() checks everything before it is
## trusted, so a missing, damaged or out-of-date file gives a message instead of a crash.

## Bump this when the file's layout changes, so an old save is recognised and refused.
const VERSION: int = 1
const FLOOR_SCENE_PREFIX: String = "res://src/world/floor_"

## Where the save lives. Static so tests can point it at a scratch file.
static var save_path: String = "user://save.json"


## True if a save file exists.
static func has_save() -> bool:
	return FileAccess.file_exists(save_path)


## Describes the current progress as a save dictionary (call write() to store it).
static func build(scene_path: String, cell: Vector2i) -> Dictionary:
	var evidence: Array = []
	for item in GameSession.inventory().items():
		evidence.append({"id": item.id, "verified": item.verified})
	return {
		"version": VERSION,
		"scene": scene_path,
		"cell": [cell.x, cell.y],
		"evidence": evidence,
		"defeated_bosses": GameSession.defeated_bosses(),
	}


## Writes a save dictionary to the save file. Returns false (and logs why) if it cannot.
static func write(data: Dictionary) -> bool:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_error("SaveGame: cannot write %s (error %d)" % [save_path, FileAccess.get_open_error()])
		return false
	file.store_string(JSON.stringify(data, "\t"))
	return true


## Reads and checks the save file. On success returns {"scene", "cell" (Vector2i),
## "evidence", "defeated_bosses"}; on any problem returns {"error": <message for the player>}.
static func read() -> Dictionary:
	if not has_save():
		return {"error": "There is no saved game yet."}
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(save_path)) != OK or not (json.data is Dictionary):
		return {"error": "That save could not be read."}
	return _validate(json.data)


## Restores a checked save (see read()) and loads its floor, placing the player on the saved tile.
static func apply(data: Dictionary, tree: SceneTree) -> void:
	GameSession.restore(data["evidence"], data["defeated_bosses"])
	FloorScene.arrival_cell = data["cell"]
	tree.change_scene_to_file(data["scene"])


## Removes the save file, if there is one.
static func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))


static func _validate(data: Dictionary) -> Dictionary:
	if int(data.get("version", -1)) != VERSION:
		return {"error": "That save is from a different version of the game."}
	var unreadable := {"error": "That save could not be read."}
	var scene: Variant = data.get("scene")
	var cell: Variant = data.get("cell")
	var evidence: Variant = data.get("evidence")
	var bosses: Variant = data.get("defeated_bosses")
	if not (scene is String) or not (scene as String).begins_with(FLOOR_SCENE_PREFIX) \
			or not ResourceLoader.exists(scene):
		return unreadable
	if not (cell is Array) or (cell as Array).size() != 2 or not (cell[0] is float) or not (cell[1] is float):
		return unreadable
	if not (evidence is Array) or not (bosses is Array):
		return unreadable
	var catalog := GameSession.inventory()
	var clean_evidence: Array = []
	for entry: Variant in evidence:
		if not (entry is Dictionary) or not ((entry as Dictionary).get("id") is String) \
				or not catalog.knows(entry["id"]) or not (entry.get("verified") is bool):
			return unreadable
		clean_evidence.append({"id": entry["id"], "verified": entry["verified"]})
	var clean_bosses: Array = []
	for boss_id: Variant in bosses:
		if not (boss_id is String):
			return unreadable
		clean_bosses.append(boss_id)
	return {
		"scene": scene,
		"cell": Vector2i(int(cell[0]), int(cell[1])),
		"evidence": clean_evidence,
		"defeated_bosses": clean_bosses,
	}
