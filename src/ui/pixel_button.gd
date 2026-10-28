class_name PixelButton
extends Button
## A menu entry: plain text that wraps, with an arrow in the left margin while it has
## keyboard focus. Meant for use under a control that has the PixelTheme applied.

const ARROW: String = "▶"


func _init() -> void:
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)


func _draw() -> void:
	if not has_focus() or disabled:
		return
	var font := get_theme_default_font()
	var size := get_theme_default_font_size()
	var text_height := font.get_height(size)
	# A one-line entry (with or without an icon) centres the arrow; a wrapped entry keeps it on
	# the first line.
	var baseline := get_theme_stylebox("normal").get_margin(SIDE_TOP) + font.get_ascent(size)
	if self.size.y < text_height * 2.0:
		baseline = (self.size.y - text_height) / 2.0 + font.get_ascent(size)
	draw_string(font, Vector2(1, baseline), ARROW, HORIZONTAL_ALIGNMENT_LEFT, -1, size, PixelTheme.INK)
