class_name EndingScreen
extends Control
## The ending, shown when the last boss is exposed. Which ending plays is chosen by the
## player's first-try accuracy (see Endings and data/endings.json). The screen shows its
## title, story text and civic message, how much evidence was verified, the accuracy, and
## the cast of bosses the player exposed. It offers a return to the title or a new run.

const FIRST_FLOOR: String = "res://src/world/floor_1.tscn"
const TITLE_SCENE: String = "res://src/ui/title_screen.tscn"

const CAST_FEET_Y: float = 296.0
## The bosses in the order they are exposed; the player stands in the middle of them.
const BOSS_SHEETS: Array[String] = [
	"deputy_director", "spokesperson", "campaign_manager",
	"director_general", "budget_secretary", "minister",
]
const CAST_SPACING: float = 64.0

@onready var _title_label: Label = %Title
@onready var _body_label: Label = %BodyLabel
@onready var _message_label: Label = %MessageLabel
@onready var _notes_label: Label = %NotesLabel
@onready var _score_label: Label = %ScoreLabel
@onready var _accuracy_label: Label = %AccuracyLabel
@onready var _action_button: Button = %ActionButton
@onready var _title_button: Button = %TitleButton
@onready var _restart_button: Button = %RestartButton
@onready var _cast: Control = %Cast

## The ending being shown (an entry of data/endings.json), for tests.
var ending: Dictionary = {}

var _lessons: Dictionary = {}
var _guide: CaseFilePanel


func _ready() -> void:
	PixelTheme.apply(self)
	_title_label.add_theme_color_override("font_color", PixelTheme.DANGER)
	_message_label.add_theme_color_override("font_color", PixelTheme.SPEAKER)
	_notes_label.add_theme_color_override("font_color", PixelTheme.MUTED)
	_score_label.add_theme_color_override("font_color", PixelTheme.NOTICE)
	_accuracy_label.add_theme_color_override("font_color", PixelTheme.AMBER)
	Audio.play_music("ending")
	ending = Endings.pick(Endings.load_all(), GameSession.accuracy_percent())
	if not ending.is_empty():
		_title_label.text = ending["title"]
		_body_label.text = ending["text"]
		_message_label.text = ending["message"]
	_notes_label.text = "
".join(Endings.notes_for(GameSession.flags()))
	_notes_label.visible = not _notes_label.text.is_empty()
	var inventory := GameSession.inventory()
	_score_label.text = "Evidence verified: %d of %d" % [inventory.verified_count(), inventory.catalog_size()]
	_accuracy_label.text = "Careful play: %d%% (%d right, %d wrong)" % [
		GameSession.accuracy_percent(), GameSession.good_choices, GameSession.wrong_choices]
	_lessons = Lessons.load_json()
	_action_button.pressed.connect(_on_action_pressed)
	_title_button.pressed.connect(_on_title_pressed)
	_restart_button.pressed.connect(_on_restart_pressed)
	_build_guide()
	_action_button.grab_focus()
	_place_cast()


## The closing "After the tower" guide, shown over the screen.
func _build_guide() -> void:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	_guide = CaseFilePanel.new()
	_guide.hide()
	_guide.closed.connect(_action_button.grab_focus)
	center.add_child(_guide)


func _on_action_pressed() -> void:
	var finale: Dictionary = _lessons.get("finale", {})
	_guide.show_pages(str(finale.get("heading", "After the tower")), Lessons.finale_pages(finale))


## Stands the exposed bosses in a row with the player in the middle.
func _place_cast() -> void:
	var count := BOSS_SHEETS.size() + 1
	var left := (get_viewport_rect().size.x - CAST_SPACING * (count - 1)) / 2.0
	var slot := 0
	for index in count:
		var sheet := "player" if index == BOSS_SHEETS.size() / 2 else BOSS_SHEETS[slot]
		if index != BOSS_SHEETS.size() / 2:
			slot += 1
		var sprite := BattleSprite.new()
		sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_cast.add_child(sprite)
		sprite.show_sheet(sheet, "down")
		sprite.place(Vector2(left + CAST_SPACING * index, CAST_FEET_Y), CharacterSprites.frame_size(sheet))


func _on_title_pressed() -> void:
	GameSession.reset()
	FloorScene.arrival_cell = null
	get_tree().change_scene_to_file(TITLE_SCENE)


func _on_restart_pressed() -> void:
	GameSession.reset()
	FloorScene.arrival_cell = null
	get_tree().change_scene_to_file(FIRST_FLOOR)
