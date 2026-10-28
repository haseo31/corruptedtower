class_name FloorPlayer
extends Node2D
## The player on a floor: moves one grid tile at a time with arrows, WASD or the
## gamepad D-pad. Turns to face a blocked tile without moving. Drawn from the player
## sheet: it faces the way it last moved, shows a walk pose for the first half of each
## step (alternating feet) and the idle pose the rest of the time.

## Emitted when a step finishes and the player stands on a new cell.
signal moved_to(cell: Vector2i)

const SHEET: String = "player"

## Seconds to walk one tile.
@export var move_time: float = 0.15

var cell: Vector2i = Vector2i.ZERO
var facing: Vector2i = Vector2i.DOWN
var is_moving: bool = false
## False while something (a conversation) has taken over the controls.
var can_move: bool = true

var _layout: FloorLayout
var _target_position: Vector2 = Vector2.ZERO
var _foot: int = 0

const _DIRECTIONS: Dictionary = {
	"move_left": Vector2i.LEFT,
	"move_right": Vector2i.RIGHT,
	"move_up": Vector2i.UP,
	"move_down": Vector2i.DOWN,
}


## Registers the movement actions (arrows, WASD, D-pad) if the project has not defined them.
static func ensure_input_actions() -> void:
	var keys: Dictionary = {
		"move_left": [KEY_LEFT, KEY_A],
		"move_right": [KEY_RIGHT, KEY_D],
		"move_up": [KEY_UP, KEY_W],
		"move_down": [KEY_DOWN, KEY_S],
	}
	keys["interact"] = [KEY_E, KEY_SPACE, KEY_ENTER]
	keys["open_evidence"] = [KEY_I]
	var buttons: Dictionary = {
		"interact": JOY_BUTTON_A,
		"open_evidence": JOY_BUTTON_Y,
		"move_left": JOY_BUTTON_DPAD_LEFT,
		"move_right": JOY_BUTTON_DPAD_RIGHT,
		"move_up": JOY_BUTTON_DPAD_UP,
		"move_down": JOY_BUTTON_DPAD_DOWN,
	}
	for action: String in keys:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		for keycode: Key in keys[action]:
			var key_event := InputEventKey.new()
			key_event.physical_keycode = keycode
			InputMap.action_add_event(action, key_event)
		var pad_event := InputEventJoypadButton.new()
		pad_event.button_index = buttons[action]
		InputMap.action_add_event(action, pad_event)


func _ready() -> void:
	ensure_input_actions()
	CharacterSprites.load_sheet(SHEET)


## Places the player on a cell of this floor.
func setup(layout: FloorLayout, start_cell: Vector2i) -> void:
	_layout = layout
	cell = start_cell
	position = layout.cell_to_world(cell)
	_target_position = position
	queue_redraw()


## Turns toward a direction, then steps if that tile is free. Returns true if a step began.
func try_move(direction: Vector2i) -> bool:
	if is_moving or not can_move:
		return false
	facing = direction
	queue_redraw()
	var target := cell + direction
	if not _layout.is_walkable(target):
		return false
	is_moving = true
	cell = target
	_foot = 1 - _foot
	_target_position = _layout.cell_to_world(target)
	var tween := create_tween()
	tween.tween_property(self, "position", _target_position, move_time)
	tween.finished.connect(_on_step_finished)
	return true


func _process(_delta: float) -> void:
	if _layout == null:
		return
	if is_moving:
		queue_redraw()
		return
	if not can_move:
		return
	for action: String in _DIRECTIONS:
		if Input.is_action_pressed(action):
			try_move(_DIRECTIONS[action])
			return


func _on_step_finished() -> void:
	is_moving = false
	queue_redraw()
	moved_to.emit(cell)


func _draw() -> void:
	if _layout == null:
		return
	var column := 0
	if is_moving:
		var progress := 1.0 - position.distance_to(_target_position) / float(_layout.tile_size)
		if progress < 0.5:
			column = 1 + _foot
	CharacterSprites.draw_frame(self, SHEET, _facing_name(), column, _layout.tile_size)


func _facing_name() -> String:
	if facing == Vector2i.UP:
		return "up"
	if facing == Vector2i.LEFT:
		return "left"
	if facing == Vector2i.RIGHT:
		return "right"
	return "down"
