class_name HowToPlayPanel
extends PanelContainer
## The HOW TO PLAY guide: a few short pages, turned with Left/Right (or Enter), closed with
## Esc. The page text is the only content; it is shown, never changed.

signal closed

const PAGES: Array = [
	["The goal", [
		"The tower is full of corruption: bribes, lies, bought votes and favours for family.",
		"Climb it floor by floor. On each floor, gather proof and expose the boss who rules it.",
		"Every boss hides behind lies. Only true, checked evidence breaks them.",
	]],
	["Moving and talking", [
		"Arrow keys or W A S D: walk.",
		"E, Space or Enter: talk to a person, or look at a desk when you stand facing it.",
		"Esc: open the pause menu (save, load, back to the title).",
		"Talk to everyone. Choose your questions with Up and Down, and answer with Enter. Different questions get different answers.",
	]],
	["Collecting evidence", [
		"People give you proof if you ask the right question. Desks with papers on them hold clues.",
		"Press I at any time to open your evidence. Each item has a short description.",
		"New evidence is unverified, marked [?]. Do not trust it until you check it.",
	]],
	["Fact-checking", [
		"Pick an item in your evidence list and choose it to start a fact-check.",
		"You see three sources about the claim. One is fake or unreliable: find it.",
		"Get it right and the item becomes verified, and you learn why that source was weak.",
		"Look for missing authors and dates, no method, rumors, and copies that were edited.",
	]],
	["Showdowns", [
		"Talk to a boss to start a showdown. The boss tells a lie.",
		"Present the evidence that disproves it. Right proof counters the lie.",
		"Wrong or unverified evidence raises the Cover-up meter. If it fills, you lose the round and try again.",
		"Counter every lie to expose the boss and unlock the stairs up.",
	]],
	["Stairs, saving and score", [
		"Stairs stay locked until that floor's boss is exposed. You can walk back down at any time.",
		"Open the pause menu with Esc and choose Save. Choose Continue on the title screen to come back.",
		"At the end, your score is how much of the evidence you verified. Check everything.",
	]],
]

var _page: int = 0
var _title_label: Label
var _body_label: Label
var _counter_label: Label


func _ready() -> void:
	PixelTheme.apply(self)
	custom_minimum_size = Vector2(380, 200)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	add_child(box)
	var heading := Label.new()
	heading.text = "HOW TO PLAY"
	heading.add_theme_color_override("font_color", PixelTheme.DANGER)
	box.add_child(heading)
	_title_label = Label.new()
	_title_label.add_theme_color_override("font_color", PixelTheme.SPEAKER)
	box.add_child(_title_label)
	_body_label = Label.new()
	_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body_label.custom_minimum_size = Vector2(360, 100)
	_body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body_label.add_theme_constant_override("line_spacing", 3)
	box.add_child(_body_label)
	var footer := HBoxContainer.new()
	box.add_child(footer)
	_counter_label = Label.new()
	_counter_label.add_theme_color_override("font_color", PixelTheme.MUTED)
	_counter_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(_counter_label)
	var hint := Label.new()
	hint.text = "Left/Right: page   Esc: back"
	hint.add_theme_color_override("font_color", PixelTheme.MUTED)
	footer.add_child(hint)
	_show_page()


## Shows the guide from its first page and takes the keyboard.
func open() -> void:
	_page = 0
	_show_page()
	show()
	grab_focus()


func _show_page() -> void:
	var page: Array = PAGES[_page]
	_title_label.text = "%d. %s" % [_page + 1, page[0]]
	_body_label.text = "\n".join(page[1])
	_counter_label.text = "Page %d of %d" % [_page + 1, PAGES.size()]


func _gui_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_right") or event.is_action_pressed("ui_accept"):
		accept_event()
		if _page == PAGES.size() - 1 and event.is_action_pressed("ui_accept"):
			closed.emit()
			return
		_page = mini(_page + 1, PAGES.size() - 1)
		_show_page()
	elif event.is_action_pressed("ui_left"):
		accept_event()
		_page = maxi(_page - 1, 0)
		_show_page()
	elif event.is_action_pressed("ui_cancel"):
		accept_event()
		closed.emit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		focus_mode = Control.FOCUS_ALL
