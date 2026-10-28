class_name JournalPanel
extends PanelContainer
## The Tower Journal: one entry per case file, in the order of the floors. A case opens once
## its boss is exposed; later ones show as locked. Choosing an unlocked entry asks the floor
## to open its case file. Esc or Back closes the journal.

signal case_selected(boss_id: String)
signal closed

var _list: VBoxContainer
var _back_button: PixelButton
var _first_focus: Control


func _ready() -> void:
	PixelTheme.apply(self)
	custom_minimum_size = Vector2(300, 0)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	add_child(box)
	var heading := Label.new()
	heading.text = Tr.t("TOWER JOURNAL")
	heading.add_theme_color_override("font_color", PixelTheme.DANGER)
	box.add_child(heading)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 2)
	box.add_child(_list)
	_back_button = PixelButton.new()
	_back_button.custom_minimum_size = Vector2(280, 0)
	_back_button.text = Tr.t("Back")
	_back_button.pressed.connect(close)
	box.add_child(_back_button)
	var note := Label.new()
	note.text = Tr.t("Expose a boss to unlock its case file.")
	note.add_theme_color_override("font_color", PixelTheme.MUTED)
	box.add_child(note)


## Shows the journal. 'cases' is Lessons.load_json()["cases"], 'order' its "order", and
## 'is_unlocked' says whether the boss with that id has been exposed.
func open(cases: Dictionary, order: Array, is_unlocked: Callable, focus_boss: String = "") -> void:
	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()
	_first_focus = null
	var focus_target: Control = null
	for boss_id: String in order:
		var button := PixelButton.new()
		button.custom_minimum_size = Vector2(280, 0)
		var unlocked: bool = is_unlocked.call(boss_id)
		button.text = cases[boss_id]["title"] if unlocked else Tr.t("Locked")
		button.disabled = not unlocked
		if unlocked:
			button.pressed.connect(case_selected.emit.bind(boss_id))
			if _first_focus == null:
				_first_focus = button
			if boss_id == focus_boss:
				focus_target = button
		_list.add_child(button)
	show()
	reset_size()
	var target := focus_target if focus_target != null else _first_focus
	if target != null:
		target.grab_focus()
	else:
		_back_button.grab_focus()


## Closes the journal.
func close() -> void:
	hide()
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
