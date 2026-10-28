class_name PixelTheme
extends RefCounted
## The one theme every panel uses: the pixel font, white boxes with a dark border, dark
## ink text, and menus whose selected entry is marked with an arrow (see PixelButton).
## Built in code so there is no hand-edited theme resource. Assign it to the root Control
## of a panel with apply(); its children inherit it.

const FONT_PATH: String = "res://assets/art/font_pixel.fnt"
const FONT_SIZE: int = 10

const INK: Color = Color("2b2233")
const PAPER: Color = Color("f8f8f0")
const MUTED: Color = Color("8a8794")
const SPEAKER: Color = Color("3a4aa0")
const NOTICE: Color = Color("2f7a5f")
const DANGER: Color = Color("b03a3a")
const AMBER: Color = Color("96620a")

static var _theme: Theme


## The shared theme, built on first use.
static func theme() -> Theme:
	if _theme == null:
		_theme = _build()
	return _theme


## Gives a panel (and so all its children) the pixel theme.
static func apply(control: Control) -> void:
	control.theme = theme()


## A white box with a dark border: the look of every panel.
static func box_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PAPER
	style.border_color = INK
	style.set_border_width_all(2)
	style.set_corner_radius_all(3)
	style.anti_aliasing = false
	style.content_margin_left = 7
	style.content_margin_right = 7
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	return style


static func _build() -> Theme:
	var t := Theme.new()
	t.default_font = load(FONT_PATH)
	t.default_font_size = FONT_SIZE

	t.set_stylebox("panel", "PanelContainer", box_style())
	t.set_color("font_color", "Label", INK)
	t.set_constant("line_spacing", "Label", 1)
	t.set_constant("separation", "VBoxContainer", 3)
	t.set_constant("separation", "HBoxContainer", 4)

	# Menu entries have no box of their own; PixelButton draws the arrow in the left margin.
	for state: String in ["normal", "hover", "pressed", "focus", "disabled"]:
		var empty := StyleBoxEmpty.new()
		empty.content_margin_left = 10
		empty.content_margin_right = 3
		empty.content_margin_top = 1
		empty.content_margin_bottom = 1
		t.set_stylebox(state, "Button", empty)
	for color_name: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color",
			"font_hover_pressed_color"]:
		t.set_color(color_name, "Button", INK)
	t.set_color("font_disabled_color", "Button", MUTED)

	# A plain list (the evidence list) highlights the selection by inverting it.
	var no_box := StyleBoxEmpty.new()
	var selected := StyleBoxFlat.new()
	selected.bg_color = INK
	selected.anti_aliasing = false
	for style_name: String in ["panel", "focus"]:
		t.set_stylebox(style_name, "ItemList", no_box)
	for style_name: String in ["selected", "selected_focus"]:
		t.set_stylebox(style_name, "ItemList", selected)
	t.set_color("font_color", "ItemList", INK)
	t.set_color("font_selected_color", "ItemList", PAPER)
	t.set_constant("v_separation", "ItemList", 2)
	return t
