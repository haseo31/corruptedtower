class_name FloorScene
extends Node2D
## One floor of the tower: draws its tiles from a layout file, places the player and the
## NPCs, keeps the camera inside the floor, and runs everything the player does there:
## talking to NPCs, picking up clues, opening the evidence screen (I), facing a boss in a
## showdown, and climbing to the next floor once the boss below is exposed. Exposing the
## last boss ends the run.

## Where the player appears on the next floor loaded by a transition.
static var arrival_cell: Variant = null

## The JSON layout this floor shows.
@export_file("*.json") var layout_path: String = ""

const ENDING_SCENE: String = "res://src/ui/ending_screen.tscn"

var _layout: FloorLayout
var _atlas: TileAtlas
var _inventory: EvidenceInventory
var _dialogues: Dictionary = {}
var _runner: DialogueRunner
var _active_boss_npc: Dictionary = {}
## The NPC nodes by cell, so one can turn to face the player.
var _npc_nodes: Dictionary = {}

@onready var _actors: Node2D = $Actors
@onready var _player: FloorPlayer = $Actors/Player
@onready var _camera: Camera2D = $Actors/Player/Camera2D
@onready var _floor_name: Label = $Hud/FloorName
@onready var _dialogue_box: DialogueBox = $Hud/DialogueBox
@onready var _evidence_screen: EvidenceScreen = $Hud/EvidenceScreen
@onready var _showdown_screen: ShowdownScreen = $Hud/ShowdownScreen


func _ready() -> void:
	_layout = FloorLayout.load_json(layout_path)
	_atlas = TileAtlas.load_atlas()
	if _layout == null or _atlas == null:
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
	_spawn_npcs()
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
	if _layout == null or _atlas == null:
		return
	var size := float(_layout.tile_size)
	for y in _layout.height:
		for x in _layout.width:
			var cell := Vector2i(x, y)
			var rect := Rect2(Vector2(cell) * size, Vector2(size, size))
			_atlas.draw_tile(self, _tile_name(cell), rect)


## Which atlas tile to draw on a cell.
func _tile_name(cell: Vector2i) -> String:
	var transition := _layout.transition_at(cell)
	if not transition.is_empty():
		return "stairs_open" if _is_unlocked(transition) else "stairs_locked"
	match _layout.tile_at(cell):
		FloorLayout.WALL:
			# A wall with floor below it shows its face; walls stacked above other walls are blocks.
			return "wall_block" if _layout.tile_at(cell + Vector2i.DOWN) == FloorLayout.WALL else "wall_face"
		FloorLayout.DESK:
			var clue := _layout.clue_at(cell)
			return "desk_paper" if not clue.is_empty() and not _inventory.has_item(clue) else "desk"
		FloorLayout.CARPET:
			return "carpet"
	return "floor"


func _spawn_npcs() -> void:
	for cell: Vector2i in _layout.npc_cells():
		var npc := _layout.npc_at(cell)
		var sheet: String = npc["sprite"]
		if not CharacterSprites.load_sheet(sheet):
			continue
		var node := FloorNpc.new()
		node.name = "Npc" + str(npc["name"]).replace(" ", "")
		_actors.add_child(node)
		node.setup(sheet, _layout.cell_to_world(cell), _layout.tile_size)
		_npc_nodes[cell] = node


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
		(_npc_nodes[cell] as FloorNpc).face(-_player.facing)
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
