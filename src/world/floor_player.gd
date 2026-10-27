class_name FloorPlayer
extends Node2D
## The player on a floor: moves one grid tile at a time with arrows, WASD or the
## gamepad D-pad. Turns to face a blocked tile without moving. Drawn as a simple
## placeholder with a facing marker, and bobs gently while standing still.

## Emitted when a step finishes and the player stands on a new cell.
signal moved_to(cell: Vector2i)

## Seconds to walk one tile.
@export var move_time: float = 0.15

var cell: Vector2i = Vector2i.ZERO
var facing: Vector2i = Vector2i.DOWN
var is_moving: bool = false
## False while something (a conversation) has taken over the controls.
var can_move: bool = true

var _layout: FloorLayout
var _idle_time: float = 0.0

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


## Places the player on a cell of this floor.
func setup(layout: FloorLayout, start_cell: Vector2i) -> void:
	_layout = layout
	cell = start_cell
	position = layout.cell_to_world(cell)
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
	var tween := create_tween()
	tween.tween_property(self, "position", _layout.cell_to_world(target), move_time)
	tween.finished.connect(_on_step_finished)
	return true


func _process(delta: float) -> void:
	if _layout == null:
		return
	if is_moving:
		queue_redraw()
		return
	_idle_time += delta
	queue_redraw()
	if not can_move:
		return
	for action: String in _DIRECTIONS:
		if Input.is_action_pressed(action):
			try_move(_DIRECTIONS[action])
			return


func _on_step_finished() -> void:
	is_moving = false
	moved_to.emit(cell)


func _draw() -> void:
	var bob := 0.0 if is_moving else sin(_idle_time * 4.0) * 1.5
	var body := Rect2(-11, -12 + bob, 22, 24)
	draw_rect(body, Color("e8c170") if is_moving else Color("f0d890"))
	draw_rect(body, Color("5a4520"), false, 2.0)
	var marker_center := Vector2(facing) * 8.0 + Vector2(0, bob)
	draw_rect(Rect2(marker_center - Vector2(3, 3), Vector2(6, 6)), Color("5a4520"))
