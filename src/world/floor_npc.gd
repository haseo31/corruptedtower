class_name FloorNpc
extends Node2D
## An NPC or boss standing on a floor tile, drawn from its character sheet. It can turn to
## face the player when spoken to, and bosses (two-column sheets) idle between two frames.

## Seconds each idle frame of a two-frame sheet is shown.
@export var idle_frame_time: float = 0.5

var _sheet_id: String = ""
var _direction: String = "down"
var _column: int = 0
var _tile_size: int = 16
var _anim_time: float = 0.0


## Places the NPC on a tile centre and picks its sprite sheet (which must already be loaded).
func setup(sheet_id: String, center: Vector2, tile_size: int) -> void:
	_sheet_id = sheet_id
	_tile_size = tile_size
	position = center
	queue_redraw()


## Turns to face this way, if the sheet has that direction. Bosses only ever face down.
func face(direction: Vector2i) -> void:
	var facing_name := "down"
	if direction == Vector2i.UP:
		facing_name = "up"
	elif direction == Vector2i.LEFT:
		facing_name = "left"
	elif direction == Vector2i.RIGHT:
		facing_name = "right"
	if CharacterSprites.has_direction(_sheet_id, facing_name):
		_direction = facing_name
		queue_redraw()


func _process(delta: float) -> void:
	if CharacterSprites.columns(_sheet_id) != 2:
		return
	_anim_time += delta
	var column := int(_anim_time / idle_frame_time) % 2
	if column != _column:
		_column = column
		queue_redraw()


func _draw() -> void:
	CharacterSprites.draw_frame(self, _sheet_id, _direction, _column, _tile_size)
