class_name TitleScreen
extends Control
## The main menu the game opens on: PLAY (or CONTINUE when a save exists), HOW TO PLAY,
## SETTINGS and EXIT over an animated picture of the tower. The guide and the settings open
## over the picture as panels. It only starts the run; the floors do the rest.

const FIRST_FLOOR: String = "res://src/world/floor_1.tscn"

@onready var _backdrop: TitleBackdrop = %Backdrop
@onready var _menu_panel: PanelContainer = %MenuPanel
@onready var _continue_button: Button = %ContinueButton
@onready var _play_button: Button = %PlayButton
@onready var _how_button: Button = %HowButton
@onready var _settings_button: Button = %SettingsButton
@onready var _exit_button: Button = %ExitButton
@onready var _status_label: Label = %StatusLabel
@onready var _hint_label: Label = %HintLabel
@onready var _overlay: Control = %Overlay
@onready var _center: CenterContainer = %Center

var _guide: HowToPlayPanel
var _settings: SettingsPanel
var _opener: Button


func _ready() -> void:
	PixelTheme.apply(self)
	GameSettings.load_and_apply()
	Audio.play_music("title")
	_status_label.add_theme_color_override("font_color", PixelTheme.DANGER)
	_hint_label.add_theme_color_override("font_color", Color("b8a8d8"))
	_backdrop.reduced_motion = GameSettings.reduce_motion
	_guide = HowToPlayPanel.new()
	_guide.hide()
	_center.add_child(_guide)
	_settings = SettingsPanel.new()
	_settings.hide()
	_center.add_child(_settings)
	_guide.closed.connect(_close_overlay)
	_settings.closed.connect(_close_overlay)
	_settings.language_changed.connect(get_tree().reload_current_scene.call_deferred)
	_continue_button.pressed.connect(_on_continue)
	_play_button.pressed.connect(_on_play)
	_how_button.pressed.connect(_on_how)
	_settings_button.pressed.connect(_on_settings)
	_exit_button.pressed.connect(get_tree().quit)
	_continue_button.visible = SaveGame.has_save()
	Tr.apply(self)
	_focus_first()


func _focus_first() -> void:
	(_continue_button if _continue_button.visible else _play_button).grab_focus()


## Gives the keyboard back to the entry that opened a panel.
func _focus_opener() -> void:
	if _opener != null:
		_opener.grab_focus()
	else:
		_focus_first()


func _on_play() -> void:
	GameSession.reset()
	FloorScene.arrival_cell = null
	get_tree().change_scene_to_file(FIRST_FLOOR)


func _on_continue() -> void:
	var save := SaveGame.read()
	if save.has("error"):
		_status_label.text = save["error"]
		return
	SaveGame.apply(save, get_tree())


func _on_how() -> void:
	_opener = _how_button
	_open_overlay(_guide)
	_guide.open()


func _on_settings() -> void:
	_opener = _settings_button
	_open_overlay(_settings)
	_settings.open()


func _open_overlay(panel: Control) -> void:
	_guide.visible = panel == _guide
	_settings.visible = panel == _settings
	_overlay.show()
	_menu_panel.hide()
	_hint_label.hide()


func _close_overlay() -> void:
	_overlay.hide()
	_guide.hide()
	_settings.hide()
	_menu_panel.show()
	_hint_label.show()
	_backdrop.reduced_motion = GameSettings.reduce_motion
	_focus_opener()
