class_name SettingsPanel
extends PanelContainer
## The SETTINGS screen: one row per option. Up and Down pick a row, Left and Right change
## it (Enter also steps it on), and each change is applied and saved at once. Esc or the
## Back row closes it. The values live in GameSettings; this only shows and edits them.

signal closed
## Emitted when the language was changed, so the screen can be built again in it.
signal language_changed

var _rows: Array[PixelButton] = []
var _row_text: Array[Callable] = []
var _row_step: Array[Callable] = []
var _note_label: Label


func _ready() -> void:
	PixelTheme.apply(self)
	custom_minimum_size = Vector2(300, 0)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	add_child(box)
	var heading := Label.new()
	heading.text = Tr.t("SETTINGS")
	heading.add_theme_color_override("font_color", PixelTheme.DANGER)
	box.add_child(heading)

	_add_row(box, func() -> String: return Tr.t("Language") + ": " + Tr.language_name(GameSettings.language),
			func(direction: int) -> void:
				var ids: Array = Tr.LANGUAGES.map(func(entry: Array) -> String: return entry[0])
				GameSettings.language = ids[posmod(ids.find(GameSettings.language) + direction, ids.size())])
	_add_row(box, func() -> String: return Tr.t("Window") + ": " + Tr.t("Fullscreen" if GameSettings.fullscreen else "Windowed"),
			func(direction: int) -> void: GameSettings.fullscreen = not GameSettings.fullscreen)
	_add_row(box, func() -> String:
			var size := GameSettings.window_size_for(GameSettings.window_scale)
			return "%s: %dx%d%s" % [Tr.t("Window size"), size.x, size.y, " " + Tr.t("(fullscreen on)") if GameSettings.fullscreen else ""],
			func(direction: int) -> void:
				GameSettings.window_scale = clampi(GameSettings.window_scale + direction, 1, GameSettings.largest_scale_that_fits()))
	_add_row(box, func() -> String: return Tr.t("Music volume") + ": " + _meter(GameSettings.music_volume),
			func(direction: int) -> void: GameSettings.music_volume = clampi(GameSettings.music_volume + direction, 0, GameSettings.MAX_VOLUME))
	_add_row(box, func() -> String: return Tr.t("Effects volume") + ": " + _meter(GameSettings.sfx_volume),
			func(direction: int) -> void: GameSettings.sfx_volume = clampi(GameSettings.sfx_volume + direction, 0, GameSettings.MAX_VOLUME))
	_add_row(box, func() -> String: return Tr.t("Text speed") + ": " + Tr.t(GameSettings.text_speed_name()),
			func(direction: int) -> void: GameSettings.text_speed_index = clampi(GameSettings.text_speed_index + direction, 0, GameSettings.TEXT_SPEEDS.size() - 1))
	_add_row(box, func() -> String: return Tr.t("Reduce motion") + ": " + Tr.t("On" if GameSettings.reduce_motion else "Off"),
			func(direction: int) -> void: GameSettings.reduce_motion = not GameSettings.reduce_motion)

	var defaults := _make_button(Tr.t("Reset to defaults"))
	defaults.pressed.connect(_on_defaults)
	box.add_child(defaults)
	var back := _make_button(Tr.t("Back"))
	back.pressed.connect(closed.emit)
	box.add_child(back)
	_note_label = Label.new()
	_note_label.add_theme_color_override("font_color", PixelTheme.MUTED)
	_note_label.text = Tr.t("Left/Right: change   Esc: back")
	box.add_child(_note_label)
	_link_focus(defaults, back)
	_refresh()


## Shows the screen with the first row selected.
func open() -> void:
	_refresh()
	show()
	reset_size()
	_rows[0].grab_focus()


func _meter(volume: int) -> String:
	return "%s%s %d" % ["#".repeat(volume), ".".repeat(GameSettings.MAX_VOLUME - volume), volume]


func _make_button(text: String) -> PixelButton:
	var button := PixelButton.new()
	button.text = text
	# A real width from the start: a wrapping button measured at zero width is very tall.
	button.custom_minimum_size = Vector2(280, 0)
	return button


func _add_row(box: VBoxContainer, text_of: Callable, step: Callable) -> void:
	var row := _make_button("")
	var index := _rows.size()
	row.gui_input.connect(_on_row_input.bind(index))
	row.pressed.connect(func() -> void: _apply_step(index, 1, true))
	box.add_child(row)
	_rows.append(row)
	_row_text.append(text_of)
	_row_step.append(step)


func _on_row_input(event: InputEvent, index: int) -> void:
	if event.is_action_pressed("ui_left"):
		row_accept(index)
		_apply_step(index, -1, false)
	elif event.is_action_pressed("ui_right"):
		row_accept(index)
		_apply_step(index, 1, false)


func row_accept(index: int) -> void:
	_rows[index].accept_event()


## Changes a row one step. A switch (window mode, reduce motion) flips either way; a pressed
## Enter on a numbered row at its top value wraps back to the lowest so it never gets stuck.
func _apply_step(index: int, direction: int, wrap: bool) -> void:
	var before := _snapshot()
	var language_before := GameSettings.language
	_row_step[index].call(direction)
	if wrap and _snapshot() == before:
		_row_step[index].call(-GameSettings.MAX_VOLUME)
	GameSettings.apply()
	GameSettings.save()
	_refresh()
	if GameSettings.language != language_before:
		language_changed.emit()


func _snapshot() -> Array:
	return [GameSettings.fullscreen, GameSettings.window_scale, GameSettings.music_volume,
			GameSettings.sfx_volume, GameSettings.text_speed_index, GameSettings.reduce_motion, GameSettings.language]


func _on_defaults() -> void:
	var language_before := GameSettings.language
	GameSettings.reset_to_defaults()
	GameSettings.apply()
	GameSettings.save()
	_refresh()
	if GameSettings.language != language_before:
		language_changed.emit()


func _refresh() -> void:
	for i in _rows.size():
		_rows[i].text = _row_text[i].call()


func _link_focus(last_row_button: Control, back: Control) -> void:
	# The rows sit in one VBox, so Up and Down already walk through them; wrap the ends.
	_rows[0].focus_neighbor_top = back.get_path()
	back.focus_neighbor_bottom = _rows[0].get_path()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		closed.emit()
