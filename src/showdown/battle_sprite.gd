class_name BattleSprite
extends Control
## One character sheet frame drawn large for the battle screen (a whole-number scale, so
## pixels stay square). A two-frame sheet (a boss) idles between its frames. The sprite's
## feet sit on the point given to place().

## Whole-number scale of the 16-bit sprite.
@export var pixel_scale: int = 2
## Seconds each idle frame of a two-frame sheet is shown.
@export var idle_frame_time: float = 0.5

var _sheet_id: String = ""
var _direction: String = "down"
var _column: int = 0
var _anim_time: float = 0.0


## Shows the first frame of a sheet row, and starts idling if the sheet has two columns.
func show_sheet(sheet_id: String, direction: String) -> void:
	_sheet_id = sheet_id
	_direction = direction
	_column = 0
	_anim_time = 0.0
	visible = CharacterSprites.load_sheet(sheet_id)
	queue_redraw()


## Puts the sprite's feet (bottom centre) on a point of the parent.
func place(feet: Vector2, frame_size: Vector2i) -> void:
	size = Vector2(frame_size) * pixel_scale
	position = feet - Vector2(size.x / 2.0, size.y)


## A short bright flash (skippable: it never blocks input).
func flash() -> void:
	modulate = Color(2.4, 2.4, 2.4)
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.18)


func _process(delta: float) -> void:
	if _sheet_id.is_empty() or CharacterSprites.columns(_sheet_id) != 2:
		return
	_anim_time += delta
	var column := int(_anim_time / idle_frame_time) % 2
	if column != _column:
		_column = column
		queue_redraw()


func _draw() -> void:
	if _sheet_id.is_empty():
		return
	draw_set_transform(Vector2(size.x / 2.0, size.y), 0.0, Vector2(pixel_scale, pixel_scale))
	CharacterSprites.draw_frame(self, _sheet_id, _direction, _column, 0)
