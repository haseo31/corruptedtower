class_name TileAtlas
extends RefCounted
## The generated tile atlas (assets/art/tiles.png) and the name -> index table beside it.
## Load it once when a floor is set up, never inside _draw().

const ART_DIR: String = "res://assets/art/"

var _texture: Texture2D
var _index: Dictionary = {}
var _tile_size: int = 16


## Loads the atlas. Returns null (and logs why) if the image or its index is missing.
static func load_atlas() -> TileAtlas:
	var atlas := TileAtlas.new()
	atlas._texture = load(ART_DIR + "tiles.png")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ART_DIR + "tiles.json"))
	if atlas._texture == null or not (parsed is Dictionary):
		push_error("TileAtlas: missing tiles.png or tiles.json in %s" % ART_DIR)
		return null
	atlas._tile_size = int((parsed as Dictionary).get("tile_size", 16))
	atlas._index = (parsed as Dictionary).get("tiles", {})
	return atlas


## Draws the named tile into dest on a canvas item. Unknown names draw nothing.
func draw_tile(canvas: CanvasItem, tile_name: String, dest: Rect2) -> void:
	if not _index.has(tile_name):
		return
	var column: int = int(_index[tile_name])
	var source := Rect2(column * _tile_size, 0, _tile_size, _tile_size)
	canvas.draw_texture_rect_region(_texture, dest, source)
