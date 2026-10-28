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
const TITLE_SCENE: String = "res://src/ui/title_screen.tscn"
## The music track for a floor theme ("" is the plain office).
const MUSIC_BY_THEME: Dictionary = {"": "office", "poll": "poll", "hr": "hr", "vault": "vault", "archive": "archive"}
## How many floors the tower has (the progress strip and the title card show it).
const TOWER_FLOORS: int = 6
## How long the floor title card stays fully visible, and how long it takes to fade.
const TITLE_CARD_HOLD: float = 2.2
const TITLE_CARD_FADE: float = 0.6

var _layout: FloorLayout
var _atlas: TileAtlas
var _inventory: EvidenceInventory
var _dialogues: Dictionary = {}
var _runner: DialogueRunner
var _active_boss_npc: Dictionary = {}
## The NPC nodes by cell, so one can turn to face the player.
var _npc_nodes: Dictionary = {}
## The case files (see Lessons) and the two panels that show them.
var _lessons: Dictionary = {}
var _case_file: CaseFilePanel
var _journal: JournalPanel

@onready var _hud: CanvasLayer = $Hud
@onready var _actors: Node2D = $Actors
@onready var _player: FloorPlayer = $Actors/Player
@onready var _camera: Camera2D = $Actors/Player/Camera2D
@onready var _floor_name_box: PanelContainer = $Hud/FloorNameBox
@onready var _floor_name: Label = $Hud/FloorNameBox/FloorName
@onready var _objective_box: PanelContainer = $Hud/ObjectiveBox
@onready var _objective_label: Label = $Hud/ObjectiveBox/Box/ObjectiveLabel
@onready var _hint_label: Label = $Hud/ObjectiveBox/Box/HintLabel
@onready var _dialogue_box: DialogueBox = $Hud/DialogueBox
@onready var _evidence_screen: EvidenceScreen = $Hud/EvidenceScreen
@onready var _showdown_screen: ShowdownScreen = $Hud/ShowdownScreen
@onready var _pause_menu: PauseMenu = $Hud/PauseMenu


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
	_showdown_screen.visibility_changed.connect(_restore_floor_music)
	for modal: Control in [_dialogue_box, _evidence_screen, _showdown_screen, _pause_menu]:
		modal.visibility_changed.connect(_refresh_lock)
	_pause_menu.save_requested.connect(_on_save_requested)
	_pause_menu.load_requested.connect(_on_load_requested)
	_pause_menu.quit_requested.connect(_on_quit_requested)
	_pause_menu.journal_requested.connect(_on_journal_requested)
	_build_lesson_panels()
	_inventory.evidence_collected.connect(_on_evidence_collected)
	var start := _layout.spawn
	if arrival_cell != null:
		if _layout.is_walkable(arrival_cell):
			start = arrival_cell
		arrival_cell = null
	Audio.play_music(MUSIC_BY_THEME.get(_layout.theme, "office"))
	_player.setup(_layout, start)
	_player.moved_to.connect(_on_player_moved)
	_spawn_npcs()
	var size := _layout.world_size()
	_camera.limit_left = 0
	_camera.limit_top = 0
	_camera.limit_right = size.x
	_camera.limit_bottom = size.y
	_camera.reset_smoothing()
	PixelTheme.apply(_floor_name_box)
	PixelTheme.apply(_objective_box)
	_floor_name.text = _layout.name
	_objective_label.add_theme_color_override("font_color", PixelTheme.DANGER)
	_hint_label.add_theme_color_override("font_color", PixelTheme.MUTED)
	_hint_label.text = _layout.hint
	_refresh_objective()
	_show_tower_progress()
	_show_title_card()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if _layout == null or _modal_open() or _player.is_moving:
		return
	if event.is_action_pressed("interact"):
		_interact_with(_player.cell + _player.facing)
	elif event.is_action_pressed("open_evidence"):
		_evidence_screen.open()
	elif event.is_action_pressed("ui_cancel"):
		_pause_menu.open(SaveGame.has_save())


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
			return _themed("wall_block" if _layout.tile_at(cell + Vector2i.DOWN) == FloorLayout.WALL else "wall_face")
		FloorLayout.DESK:
			var clue := _layout.clue_at(cell)
			return _themed("desk_paper" if not clue.is_empty() and not _inventory.has_item(clue) else "desk")
		FloorLayout.CARPET:
			return _themed("carpet")
	return _themed("floor")


## The tile name for this floor's theme ("floor" becomes "floor_poll" on a themed floor).
func _themed(base: String) -> String:
	return base if _layout.theme.is_empty() else "%s_%s" % [base, _layout.theme]


func _spawn_npcs() -> void:
	for cell: Vector2i in _layout.npc_cells():
		var npc := _layout.npc_at(cell)
		if not _npc_visible(npc):
			continue
		var sheet: String = npc["sprite"]
		if not CharacterSprites.load_sheet(sheet):
			continue
		var node := FloorNpc.new()
		node.name = "Npc" + str(npc["name"]).replace(" ", "")
		_actors.add_child(node)
		node.setup(sheet, _layout.cell_to_world(cell), _layout.tile_size)
		_npc_nodes[cell] = node


## The strip of floor boxes under the floor name, showing how far up the tower the player is.
func _show_tower_progress() -> void:
	if _layout.floor_number < 1:
		return
	var strip := TowerProgress.new()
	strip.position = Vector2(4, 24)
	_hud.add_child(strip)
	# Right after the floor name, so every panel (dialogue, evidence, showdown) draws over it.
	_hud.move_child(strip, _floor_name_box.get_index() + 1)
	strip.setup(_layout.floor_number, TOWER_FLOORS)


## A card with the floor's name and goal, shown for a moment when the player arrives.
func _show_title_card() -> void:
	if _layout.floor_number < 1:
		return
	var card := PanelContainer.new()
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	PixelTheme.apply(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	card.add_child(box)
	var count := Label.new()
	count.text = "FLOOR %d OF %d" % [_layout.floor_number, TOWER_FLOORS]
	count.add_theme_color_override("font_color", PixelTheme.DANGER)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(count)
	var title := Label.new()
	title.text = _layout.name.get_slice(": ", 1) if ": " in _layout.name else _layout.name
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var goal := Label.new()
	goal.text = _layout.objective
	goal.add_theme_color_override("font_color", PixelTheme.MUTED)
	goal.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(goal)
	_hud.add_child(card)
	_hud.move_child(card, _floor_name_box.get_index() + 1)
	card.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 0)
	card.position.y = 56.0
	Audio.play_sfx("floor_start")
	var tween := create_tween()
	tween.tween_interval(TITLE_CARD_HOLD)
	if not ShowdownScreen.reduce_motion:
		tween.tween_property(card, "modulate:a", 0.0, TITLE_CARD_FADE)
	tween.tween_callback(card.queue_free)


## The case file and journal panels, centred on the screen above every other panel.
func _build_lesson_panels() -> void:
	_lessons = Lessons.load_json()
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.add_child(center)
	_case_file = CaseFilePanel.new()
	_case_file.hide()
	center.add_child(_case_file)
	_journal = JournalPanel.new()
	_journal.hide()
	_journal.case_selected.connect(_on_journal_case_selected)
	center.add_child(_journal)
	for panel: Control in [_case_file, _journal]:
		panel.visibility_changed.connect(_refresh_lock)


## Shows the case file for an exposed boss, then calls 'then'. With no case file for the
## boss, calls 'then' at once.
func _show_case_file(boss_id: String, then: Callable) -> void:
	var cases: Dictionary = _lessons.get("cases", {})
	if not cases.has(boss_id):
		then.call()
		return
	_case_file.closed.connect(then, CONNECT_ONE_SHOT)
	_case_file.show_pages(cases[boss_id]["title"], Lessons.case_pages(cases[boss_id]))


func _on_journal_requested() -> void:
	_pause_menu.close()
	_open_journal("")


func _open_journal(focus_boss: String) -> void:
	_journal.open(_lessons.get("cases", {}), _lessons.get("order", []), GameSession.is_defeated, focus_boss)


func _on_journal_case_selected(boss_id: String) -> void:
	_journal.hide()
	_show_case_file(boss_id, _open_journal.bind(boss_id))


## A character can appear only after a choice ("requires_flag") or vanish after one ("hide_if_flag").
func _npc_visible(npc: Dictionary) -> bool:
	var needs: String = npc.get("requires_flag", "")
	var hides: String = npc.get("hide_if_flag", "")
	return (needs.is_empty() or GameSession.has_flag(needs)) and (hides.is_empty() or not GameSession.has_flag(hides))


func _modal_open() -> bool:
	return _dialogue_box.visible or _evidence_screen.visible or _showdown_screen.visible 			or _pause_menu.visible or _case_file.visible or _journal.visible


func _refresh_lock() -> void:
	_player.can_move = not _modal_open()
	_refresh_objective()


## Shows the floor's objective (the next one once its boss is exposed), hidden while a
## panel is open or when there is nothing to say.
func _refresh_objective() -> void:
	var boss_done := not _layout.objective_boss.is_empty() and GameSession.is_defeated(_layout.objective_boss)
	_objective_label.text = _layout.objective_done if boss_done else _layout.objective
	_objective_box.visible = not _modal_open() and not _objective_label.text.is_empty()


func _is_unlocked(transition: Dictionary) -> bool:
	var needed: String = transition["requires_boss"]
	return needed.is_empty() or GameSession.is_defeated(needed)


func _interact_with(cell: Vector2i) -> void:
	var npc := _layout.npc_at(cell)
	if not npc.is_empty() and _npc_visible(npc):
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
	Audio.play_music(boss.music)
	Audio.play_sfx("boss_intro")
	_showdown_screen.start(boss, _inventory)


func _restore_floor_music() -> void:
	if not _showdown_screen.visible:
		Audio.play_music(MUSIC_BY_THEME.get(_layout.theme, "office"))


func _on_showdown_won(boss_id: String) -> void:
	GameSession.mark_defeated(boss_id)
	_refresh_objective()
	queue_redraw()
	_show_case_file(boss_id, _after_case_file)


## What happens once the case file after a boss is closed: the ending, or the boss's last words.
func _after_case_file() -> void:
	if _active_boss_npc.get("final", false):
		get_tree().change_scene_to_file(ENDING_SCENE)
	else:
		_runner.start(DialogueRunner.message_dialogue(_active_boss_npc["name"], _active_boss_npc["defeated_message"]))


func _on_quit_requested() -> void:
	get_tree().change_scene_to_file(TITLE_SCENE)


func _on_save_requested() -> void:
	if SaveGame.write(SaveGame.build(scene_file_path, _player.cell)):
		Audio.play_sfx("save")
		_pause_menu.show_message("Game saved.", true)
	else:
		_pause_menu.show_message("Could not save the game.", false)


func _on_load_requested() -> void:
	var save := SaveGame.read()
	if save.has("error"):
		_pause_menu.show_message(save["error"], false)
		return
	SaveGame.apply(save, get_tree())


func _on_evidence_collected(_evidence_id: String) -> void:
	Audio.play_sfx("pickup")
	queue_redraw()


func _on_player_moved(cell: Vector2i) -> void:
	var transition := _layout.transition_at(cell)
	if transition.is_empty():
		Audio.play_sfx("step")
		return
	if not _is_unlocked(transition):
		Audio.play_sfx("locked")
		_runner.start(DialogueRunner.message_dialogue("", transition["locked_message"]))
		return
	Audio.play_sfx("stairs")
	arrival_cell = transition["spawn"]
	get_tree().change_scene_to_file(transition["scene"])
