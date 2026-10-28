class_name EvidenceIcons
extends RefCounted
## The generated evidence icons (assets/art/icons.png) as small textures, by evidence id.
## Used beside evidence names in menus. Load them while building a menu, never in _draw().

const ART_DIR: String = "res://assets/art/"

static var _atlas: Texture2D
static var _index: Dictionary = {}
static var _size: int = 16
static var _cache: Dictionary = {}


## The icon for this evidence id, or null if there is none.
static func texture_for(evidence_id: String) -> Texture2D:
	if _atlas == null:
		_load()
	if not _index.has(evidence_id):
		return null
	if not _cache.has(evidence_id):
		var texture := AtlasTexture.new()
		texture.atlas = _atlas
		texture.region = Rect2(int(_index[evidence_id]) * _size, 0, _size, _size)
		_cache[evidence_id] = texture
	return _cache[evidence_id]


static func _load() -> void:
	_atlas = load(ART_DIR + "icons.png")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ART_DIR + "icons.json"))
	if _atlas == null or not (parsed is Dictionary):
		push_error("EvidenceIcons: missing icons.png or icons.json in %s" % ART_DIR)
		return
	_size = int((parsed as Dictionary).get("icon_size", 16))
	_index = (parsed as Dictionary).get("icons", {})
