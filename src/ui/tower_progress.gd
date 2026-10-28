class_name TowerProgress
extends Control
## A small strip of boxes, one per floor of the tower: floors already climbed are green, the
## floor the player is on is red, and the floors above are empty. Display only.

const BOX: int = 8
const GAP: int = 3
const PAD: int = 3

var _current: int = 0
var _total: int = 0


## Shows this floor (1-based) out of this many.
func setup(current: int, total: int) -> void:
	_current = current
	_total = total
	custom_minimum_size = Vector2(PAD * 2 + _total * BOX + (_total - 1) * GAP, PAD * 2 + BOX)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	if _total < 1:
		return
	draw_rect(Rect2(Vector2.ZERO, size), PixelTheme.INK)
	draw_rect(Rect2(Vector2.ONE, size - Vector2(2, 2)), PixelTheme.PAPER)
	for i in _total:
		var floor_number := i + 1
		var rect := Rect2(Vector2(PAD + i * (BOX + GAP), PAD), Vector2(BOX, BOX))
		draw_rect(rect, PixelTheme.INK)
		var fill := PixelTheme.PAPER
		if floor_number < _current:
			fill = PixelTheme.NOTICE
		elif floor_number == _current:
			fill = PixelTheme.DANGER
		draw_rect(rect.grow(-1), fill)
