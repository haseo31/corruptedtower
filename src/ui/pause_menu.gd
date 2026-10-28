class_name PauseMenu
extends Control
## The pause menu on a floor: Resume, Save, Load, Tower Journal, Settings and Quit, with a one-line message about what
## just happened. It only displays and reports the player's choice; the floor does the saving.
## Esc closes it. Keyboard only.

signal save_requested
signal load_requested
signal journal_requested
signal settings_requested
signal quit_requested

@onready var _resume_button: Button = %ResumeButton
@onready var _save_button: Button = %SaveButton
@onready var _load_button: Button = %LoadButton
@onready var _journal_button: Button = %JournalButton
@onready var _settings_button: Button = %SettingsButton
@onready var _quit_button: Button = %QuitButton
@onready var _status_label: Label = %StatusLabel


func _ready() -> void:
	PixelTheme.apply(self)
	Tr.apply(self)
	_resume_button.pressed.connect(close)
	_save_button.pressed.connect(save_requested.emit)
	_load_button.pressed.connect(load_requested.emit)
	_journal_button.pressed.connect(journal_requested.emit)
	_settings_button.pressed.connect(settings_requested.emit)
	_quit_button.pressed.connect(quit_requested.emit)


## Opens the menu on Resume. Load is greyed out when there is no save to load.
func open(has_save: bool) -> void:
	_load_button.disabled = not has_save
	_status_label.text = "" if has_save else Tr.t("There is no saved game yet.")
	_status_label.add_theme_color_override("font_color", PixelTheme.MUTED)
	show()
	_resume_button.grab_focus()


## Closes the menu.
func close() -> void:
	hide()


## Shows a message under the buttons: green for good news, red for a problem. Saving also
## enables Load, since there is now something to load.
func show_message(text: String, good: bool) -> void:
	_status_label.text = text
	_status_label.add_theme_color_override("font_color", PixelTheme.NOTICE if good else PixelTheme.DANGER)
	if good:
		_load_button.disabled = false


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
