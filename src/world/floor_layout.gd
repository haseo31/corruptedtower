class_name FloorLayout
extends RefCounted
## One floor of the tower as a grid: walls and furniture block movement, transition
## tiles lead to another floor, NPCs stand on floor tiles, and evidence clues lie on
## desk tiles. Loaded from a data file so layouts never live in code.

const WALL: String = "#"
const DESK: String = "D"
const FLOOR: String = "."
## A carpeted floor tile: walkable, drawn differently.
const CARPET: String = "c"

var name: String = ""
## Which tile set the floor is drawn with: "" for the default look, or a theme id such as "poll".
var theme: String = ""
## Which floor of the tower this is (1 is the ground floor); 0 for none.
var floor_number: int = 0
var tile_size: int = 32
var width: int = 0
var height: int = 0
## Where the player starts when no other arrival cell is given.
var spawn: Vector2i = Vector2i.ZERO
## A short controls hint shown on the floor.
var hint: String = ""
## What to do on this floor, and what to do once the boss named by objective_boss is exposed.
var objective: String = ""
var objective_done: String = ""
var objective_boss: String = ""

var _rows: Array[String] = []
## Transition cells: Vector2i -> {"scene": String, "spawn": Vector2i}.
var _transitions: Dictionary = {}
## NPC cells: Vector2i -> {"name", "sprite" (a character sheet id), "dialogue", "boss" (a boss data path, or ""), "final", "defeated_message"}.
var _npcs: Dictionary = {}
## Clue cells (on desks): Vector2i -> evidence id.
var _clues: Dictionary = {}


## Loads a floor from a JSON file. Returns null (and logs why) if it is missing or invalid.
static func load_json(path: String) -> FloorLayout:
	if not FileAccess.file_exists(path):
		push_error("FloorLayout: file not found: %s" % path)
		return null
	var parsed: Variant = Tr.tree(JSON.parse_string(FileAccess.get_file_as_string(path)))
	if not (parsed is Dictionary):
		push_error("FloorLayout: %s is not a JSON object" % path)
		return null
	return from_dict(parsed)


## Builds a floor from a parsed data dictionary. Returns null (and logs why) if it is invalid.
static func from_dict(data: Dictionary) -> FloorLayout:
	var layout := FloorLayout.new()
	layout.name = str(data.get("name", ""))
	layout.tile_size = int(data.get("tile_size", 0))
	layout.theme = str(data.get("theme", ""))
	layout.floor_number = int(data.get("floor_number", 0))
	layout.hint = str(data.get("hint", ""))
	layout.objective = str(data.get("objective", ""))
	layout.objective_done = str(data.get("objective_done", ""))
	layout.objective_boss = str(data.get("objective_boss", ""))
	var row_entries: Variant = data.get("rows", [])
	if not (row_entries is Array) or (row_entries as Array).is_empty() or layout.tile_size < 1:
		push_error("FloorLayout: needs tile_size >= 1 and a non-empty 'rows' list")
		return null
	for row: Variant in row_entries:
		layout._rows.append(str(row))
	layout.height = layout._rows.size()
	layout.width = layout._rows[0].length()
	for row in layout._rows:
		if row.length() != layout.width:
			push_error("FloorLayout: every row must be %d tiles wide" % layout.width)
			return null
	var transition_entries: Variant = data.get("transitions", [])
	if transition_entries is Array:
		for entry: Variant in transition_entries:
			if entry is Dictionary:
				var cell := Vector2i(int(entry.get("x", -1)), int(entry.get("y", -1)))
				layout._transitions[cell] = {
					"scene": str(entry.get("scene", "")),
					"spawn": _to_cell(entry.get("spawn", [0, 0])),
					"requires_boss": str(entry.get("requires_boss", "")),
					"locked_message": str(entry.get("locked_message", "")),
				}
	var npc_entries: Variant = data.get("npcs", [])
	if npc_entries is Array:
		for entry: Variant in npc_entries:
			if not (entry is Dictionary):
				continue
			var cell := Vector2i(int(entry.get("x", -1)), int(entry.get("y", -1)))
			if not _is_floor_tile(layout.tile_at(cell)):
				push_error("FloorLayout: NPC at %s must stand on a floor tile" % cell)
				return null
			layout._npcs[cell] = {
				"name": str(entry.get("name", "")),
				"sprite": str(entry.get("sprite", "")),
				"dialogue": str(entry.get("dialogue", "")),
				"boss": str(entry.get("boss", "")),
				"final": bool(entry.get("final", false)),
				"defeated_message": str(entry.get("defeated_message", "")),
				"requires_flag": str(entry.get("requires_flag", "")),
				"hide_if_flag": str(entry.get("hide_if_flag", "")),
			}
	var clue_entries: Variant = data.get("clues", [])
	if clue_entries is Array:
		for entry: Variant in clue_entries:
			if not (entry is Dictionary):
				continue
			var cell := Vector2i(int(entry.get("x", -1)), int(entry.get("y", -1)))
			if layout.tile_at(cell) != DESK:
				push_error("FloorLayout: clue at %s must lie on a desk tile" % cell)
				return null
			layout._clues[cell] = str(entry.get("evidence_id", ""))
	layout.spawn = _to_cell(data.get("spawn", [0, 0]))
	if not layout.is_walkable(layout.spawn):
		push_error("FloorLayout: spawn %s is not a walkable tile" % layout.spawn)
		return null
	return layout


## The tile character at this cell; walls for anything outside the floor.
func tile_at(cell: Vector2i) -> String:
	if cell.x < 0 or cell.y < 0 or cell.x >= width or cell.y >= height:
		return WALL
	return _rows[cell.y][cell.x]


## True if the player can stand on this cell (walls, furniture and NPCs block).
func is_walkable(cell: Vector2i) -> bool:
	return _is_floor_tile(tile_at(cell)) and not _npcs.has(cell)


## The transition on this cell ({"scene", "spawn", "requires_boss", "locked_message"}), or an empty dictionary.
func transition_at(cell: Vector2i) -> Dictionary:
	return _transitions.get(cell, {})


## All transition cells on this floor.
func transition_cells() -> Array:
	return _transitions.keys()


## The NPC on this cell (see _npcs), or an empty dictionary.
func npc_at(cell: Vector2i) -> Dictionary:
	return _npcs.get(cell, {})


## All NPC cells on this floor.
func npc_cells() -> Array:
	return _npcs.keys()


## The evidence id of the clue lying on this cell, or an empty string.
func clue_at(cell: Vector2i) -> String:
	return str(_clues.get(cell, ""))


## All clue cells on this floor.
func clue_cells() -> Array:
	return _clues.keys()


## The world position of the centre of a cell.
func cell_to_world(cell: Vector2i) -> Vector2:
	return (Vector2(cell) + Vector2(0.5, 0.5)) * tile_size


## The size of the whole floor in pixels.
func world_size() -> Vector2i:
	return Vector2i(width, height) * tile_size


static func _is_floor_tile(tile: String) -> bool:
	return tile == FLOOR or tile == CARPET


static func _to_cell(value: Variant) -> Vector2i:
	if value is Array and (value as Array).size() == 2:
		return Vector2i(int(value[0]), int(value[1]))
	return Vector2i.ZERO
