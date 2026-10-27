class_name FloorScene
extends Node2D
## One floor of the tower: draws its grid from a layout file, places the player, keeps
## the camera inside the floor, and runs everything the player does there: talking to
## NPCs, picking up clues, opening the evidence screen (I), facing a boss in a showdown,
## and climbing to the next floor once the boss below is exposed. Exposing the last
## boss ends the run.

## Where the player appears on the next floor loaded by a transition.
static var arrival_cell: Variant = null

## The JSON layout this floor shows.
@export_file("*.json") var layout_path: String = ""

const ENDING_SCENE: String = "res://src/ui/ending_screen.tscn"

const _COLOR_FLOOR: Color = Color("3a4252")
const _COLOR_WALL: Color = Color("1c1f27")
const _COLOR_DESK: Color = Color("7a5836")
const _COLOR_TRANSITION: Color = Color("2f9e8f")
const _COLOR_LOCKED: Color = Color("a64a4a")
const _COLOR_GRID: Color = Color(0, 0, 0, 0.25)
const _COLOR_NPC: Color = Color("9a6fd0")
const _COLOR_BOSS: Color = Color("d05a5a")
const _COLOR_BOSS_DEFEATED: Color = Color("6b5050")
const _COLOR_CLUE: Color = Color("f2efe4")
const _COLOR_LABEL: Color = Color("e8e6f0")

var _layout: FloorLayout
var _inventory: EvidenceInventory
var _dialogues: Dictionary = {}
var _runner: DialogueRunner
var _active_boss_npc: Dictionary = {}

@onready var _player: FloorPlayer = $Player
@onready var _camera: Camera2D = $Player/Camera2D
@onready var _floor_name: Label = $Hud/FloorName
@onready var _dialogue_box: DialogueBox = $Hud/DialogueBox
@onready var _evidence_screen: EvidenceScreen = $Hud/EvidenceScreen
@onready var _showdown_screen: ShowdownScreen = $Hud/ShowdownScreen


func _ready() -> void:
	_layout = FloorLayout.load_json(layout_path)
	if _layout == null:
		return
	_inventory = GameSession.inventory()
	_dialogues = GameSession.dialogues()
	_runner = DialogueRunner.new(_inventory)
	_dialogue_box.bind(_runner, _inventory)
	_evidence_screen.bind(_inventory, GameSession.challenges())
	_showdown_screen.showdown_won.connect(_on_showdown_won)
	for modal: Control in [_dialogue_box, _evidence_screen, _showdown_screen]:
		modal.visibility_changed.connect(_refresh_lock)
	_inventory.evidence_collected.connect(_on_evidence_collected)
	var start := _layout.spawn
	if arrival_cell != null:
		start = arrival_cell
		arrival_cell = null
	_player.setup(_layout, start)
	_player.moved_to.connect(_on_player_moved)
	var size := _layout.world_size()
	_camera.limit_left = 0
	_camera.limit_top = 0
	_camera.limit_right = size.x
	_camera.limit_bottom = size.y
	_camera.reset_smoothing()
	_floor_name.text = _layout.name
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if _layout == null or _modal_open() or _player.is_moving:
		return
	if event.is_action_pressed("interact"):
		_interact_with(_player.cell + _player.facing)
	elif event.is_action_pressed("open_evidence"):
		_evidence_screen.open()


func _draw() -> void:
	if _layout == null:
		return
	var tile := Vector2(_layout.tile_size, _layout.tile_size)
	for y in _layout.height:
		for x in _layout.width:
			var cell := Vector2i(x, y)
			var color := _COLOR_FLOOR
			match _layout.tile_at(cell):
				FloorLayout.WALL:
					color = _COLOR_WALL
				FloorLayout.DESK:
					color = _COLOR_DESK
			var transition := _layout.transition_at(cell)
			if not transition.is_empty():
				color = _COLOR_TRANSITION if _is_unlocked(transition) else _COLOR_LOCKED
			var rect := Rect2(Vector2(cell) * _layout.tile_size, tile)
			draw_rect(rect, color)
			draw_rect(rect, _COLOR_GRID, false, 1.0)
	for cell: Vector2i in _layout.clue_cells():
		if not _inventory.has_item(_layout.clue_at(cell)):
			var center := _layout.cell_to_world(cell)
			draw_rect(Rect2(center - Vector2(8, 6), Vector2(16, 12)), _COLOR_CLUE)
			draw_rect(Rect2(center - Vector2(8, 6), Vector2(16, 12)), _COLOR_WALL, false, 1.0)
	var font := ThemeDB.fallback_font
	for cell: Vector2i in _layout.npc_cells():
		var npc := _layout.npc_at(cell)
		var center := _layout.cell_to_world(cell)
		draw_circle(center, 12.0, _npc_color(npc))
		draw_string(font, center + Vector2(-60, -18), npc["name"],
				HORIZONTAL_ALIGNMENT_CENTER, 120, 13, _COLOR_LABEL)


func _npc_color(npc: Dictionary) -> Color:
	if str(npc["boss"]).is_empty():
		return _COLOR_NPC
	var boss := BossData.load_json(npc["boss"])
	if boss != null and GameSession.is_defeated(boss.id):
		return _COLOR_BOSS_DEFEATED
	return _COLOR_BOSS


func _modal_open() -> bool:
	return _dialogue_box.visible or _evidence_screen.visible or _showdown_screen.visible


func _refresh_lock() -> void:
	_player.can_move = not _modal_open()


func _is_unlocked(transition: Dictionary) -> bool:
	var needed: String = transition["requires_boss"]
	return needed.is_empty() or GameSession.is_defeated(needed)


func _interact_with(cell: Vector2i) -> void:
	var npc := _layout.npc_at(cell)
	if not npc.is_empty():
		if not str(npc["boss"]).is_empty():
			_talk_to_boss(npc)
		elif _dialogues.has(npc["dialogue"]):
			_runner.start(_dialogues[npc["dialogue"]])
		return
	var evidence_id := _layout.clue_at(cell)
	if not evidence_id.is_empty() and not _inventory.has_item(evidence_id):
		_runner.start(DialogueRunner.pickup_dialogue("You pick up a document lying on the desk.", evidence_id))


func _talk_to_boss(npc: Dictionary) -> void:
	var boss := BossData.load_json(npc["boss"])
	if boss == null:
		return
	if GameSession.is_defeated(boss.id):
		_runner.start(DialogueRunner.message_dialogue(npc["name"], npc["defeated_message"]))
		return
	_active_boss_npc = npc
	_showdown_screen.start(boss, _inventory)


func _on_showdown_won(boss_id: String) -> void:
	GameSession.mark_defeated(boss_id)
	queue_redraw()
	if _active_boss_npc.get("final", false):
		get_tree().change_scene_to_file(ENDING_SCENE)
	else:
		_runner.start(DialogueRunner.message_dialogue(_active_boss_npc["name"], _active_boss_npc["defeated_message"]))


func _on_evidence_collected(_evidence_id: String) -> void:
	queue_redraw()


func _on_player_moved(cell: Vector2i) -> void:
	var transition := _layout.transition_at(cell)
	if transition.is_empty():
		return
	if not _is_unlocked(transition):
		_runner.start(DialogueRunner.message_dialogue("", transition["locked_message"]))
		return
	arrival_cell = transition["spawn"]
	get_tree().change_scene_to_file(transition["scene"])
