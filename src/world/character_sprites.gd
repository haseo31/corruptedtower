class_name CharacterSprites
extends RefCounted
## Loads the generated character sheets (assets/art/char_<id>.png) once and draws one frame
## of one. The sheet layout (frame size, columns, row order) comes from characters.json.
## Call load_sheet() when a floor is set up; draw_frame() only reads the cache, because a
## texture first loaded inside _draw() comes out as a blank placeholder.

const ART_DIR: String = "res://assets/art/"

static var _info: Dictionary = {}
static var _sheets: Dictionary = {}


## Loads a sheet into the cache. Returns false (and logs why) if it is unknown or missing.
static func load_sheet(sheet_id: String) -> bool:
	if _sheets.has(sheet_id):
		return true
	if _info.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ART_DIR + "characters.json"))
		if parsed is Dictionary:
			_info = parsed
	if not _info.has(sheet_id):
		push_error("CharacterSprites: no sheet '%s' in characters.json" % sheet_id)
		return false
	var texture: Texture2D = load(ART_DIR + "char_%s.png" % sheet_id)
	if texture == null:
		push_error("CharacterSprites: could not load char_%s.png" % sheet_id)
		return false
	_sheets[sheet_id] = texture
	return true


## The number of animation columns in a loaded sheet (3 for walkers, 2 for bosses).
static func columns(sheet_id: String) -> int:
	return int(_info[sheet_id]["columns"]) if _info.has(sheet_id) else 0


## True if the sheet has a row for this direction ("down", "up", "left", "right").
static func has_direction(sheet_id: String, direction: String) -> bool:
	return _info.has(sheet_id) and (_info[sheet_id]["rows"] as Array).has(direction)


## Draws a frame with its feet on the bottom edge of the tile whose centre is the canvas
## item's origin. A direction the sheet lacks falls back to its first row.
static func draw_frame(canvas: CanvasItem, sheet_id: String, direction: String, column: int, tile_size: int) -> void:
	if not _sheets.has(sheet_id):
		return
	var size := Vector2((_info[sheet_id]["frame"] as Array)[0], (_info[sheet_id]["frame"] as Array)[1])
	var rows: Array = _info[sheet_id]["rows"]
	var row := maxi(rows.find(direction), 0)
	var top_left := Vector2(-size.x / 2.0, tile_size / 2.0 - size.y)
	var source := Rect2(Vector2(column * size.x, row * size.y), size)
	canvas.draw_texture_rect_region(_sheets[sheet_id], Rect2(top_left, size), source)
