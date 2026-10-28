class_name BattleBackdrop
extends Control
## The plain office backdrop of the battle screen: a wall, a floor, and an oval platform
## under each fighter. Drawn from shapes; it holds no game state.

const WALL: Color = Color("cfd8e6")
const WALL_LINE: Color = Color("bcc7da")
const FLOOR: Color = Color("97a8c2")
const FLOOR_LINE: Color = Color("8798b4")
const PLATFORM: Color = Color("e4e9f2")
const PLATFORM_EDGE: Color = Color("6b7a96")
const HORIZON: int = 120

## Platform centres (boss, player) and half-sizes.
@export var boss_platform: Vector2 = Vector2(350, 104)
@export var player_platform: Vector2 = Vector2(130, 190)
@export var platform_half_size: Vector2 = Vector2(54, 10)


func _draw() -> void:
	draw_rect(Rect2(0, 0, size.x, HORIZON), WALL)
	for x in range(0, int(size.x), 32):
		draw_line(Vector2(x, 0), Vector2(x, HORIZON), WALL_LINE)
	draw_rect(Rect2(0, HORIZON, size.x, size.y - HORIZON), FLOOR)
	for y in range(HORIZON + 8, int(size.y), 16):
		draw_line(Vector2(0, y), Vector2(size.x, y), FLOOR_LINE)
	_draw_platform(boss_platform)
	_draw_platform(player_platform)


func _draw_platform(center: Vector2) -> void:
	draw_colored_polygon(_ellipse(center + Vector2(0, 3), platform_half_size), PLATFORM_EDGE)
	draw_colored_polygon(_ellipse(center, platform_half_size), PLATFORM)


func _ellipse(center: Vector2, half_size: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 40:
		var angle := TAU * i / 40.0
		points.append(center + Vector2(cos(angle) * half_size.x, sin(angle) * half_size.y))
	return points
