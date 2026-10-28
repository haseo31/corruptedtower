class_name CaseFilePanel
extends PanelContainer
## A few pages of text, turned with Left and Right (or Enter), closed with Esc or Enter on
## the last page. Used for the case file after each boss, for the Tower Journal and for the
## closing guide. The pages are only shown, never changed.

signal closed

var _pages: Array = []
var _page: int = 0
var _heading_label: Label
var _title_label: Label
var _body_label: Label
var _footer_label: Label
var _counter_label: Label


func _ready() -> void:
	PixelTheme.apply(self)
	custom_minimum_size = Vector2(440, 0)
	focus_mode = Control.FOCUS_ALL
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 5)
	add_child(box)
	_heading_label = Label.new()
	_heading_label.add_theme_color_override("font_color", PixelTheme.DANGER)
	box.add_child(_heading_label)
	_title_label = Label.new()
	_title_label.add_theme_color_override("font_color", PixelTheme.SPEAKER)
	_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_title_label)
	_body_label = Label.new()
	_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body_label.custom_minimum_size = Vector2(420, 112)
	_body_label.add_theme_constant_override("line_spacing", 3)
	box.add_child(_body_label)
	_footer_label = Label.new()
	_footer_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_footer_label.custom_minimum_size = Vector2(420, 0)
	_footer_label.add_theme_color_override("font_color", PixelTheme.MUTED)
	box.add_child(_footer_label)
	var bar := HBoxContainer.new()
	box.add_child(bar)
	_counter_label = Label.new()
	_counter_label.add_theme_color_override("font_color", PixelTheme.MUTED)
	_counter_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(_counter_label)
	var hint := Label.new()
	hint.text = "Left/Right: page   Esc: close"
	hint.add_theme_color_override("font_color", PixelTheme.MUTED)
	bar.add_child(hint)


## Shows these pages ([{"title", "body", "footer"}]) from the first one and takes the keyboard.
func show_pages(heading: String, pages: Array) -> void:
	_pages = pages
	_page = 0
	_heading_label.text = heading
	_show_page()
	show()
	grab_focus()


func _show_page() -> void:
	if _pages.is_empty():
		return
	var page: Dictionary = _pages[_page]
	_title_label.text = "%d. %s" % [_page + 1, page["title"]]
	_body_label.text = page["body"]
	_footer_label.text = page["footer"]
	_footer_label.visible = not _footer_label.text.is_empty()
	_counter_label.text = "Page %d of %d" % [_page + 1, _pages.size()]


func _gui_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_right") or event.is_action_pressed("ui_accept"):
		accept_event()
		if _page == _pages.size() - 1 and event.is_action_pressed("ui_accept"):
			_close()
			return
		_page = mini(_page + 1, _pages.size() - 1)
		_show_page()
	elif event.is_action_pressed("ui_left"):
		accept_event()
		_page = maxi(_page - 1, 0)
		_show_page()
	elif event.is_action_pressed("ui_cancel"):
		accept_event()
		_close()


func _close() -> void:
	hide()
	closed.emit()
