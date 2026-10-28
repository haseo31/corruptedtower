class_name TitleBackdrop
extends Control
## The animated picture behind the main menu, drawn entirely from rectangles and lines in
## the 480x320 pixel grid: a night sky with stars and a moon, a ruined skyline, the tower
## with flickering windows, glowing cracks and a red beacon, the player at its door, drifting
## fog, rising embers, and the glitching game title. With reduced motion everything holds
## still. It is only a picture; the menu lives in TitleScreen.

const SCREEN: Vector2 = Vector2(480, 320)
const GROUND_Y: int = 296
const TOWER_X: int = 140
const HORIZON_Y: int = 236
const STAR_COUNT: int = 70
const EMBER_COUNT: int = 30
const FOG_COUNT: int = 14
const GLITCH_PERIOD: float = 4.0
const GLITCH_LENGTH: float = 0.2

const SKY_TOP: Color = Color("0b0d22")
const SKY_MID: Color = Color("2a1740")
const SKY_LOW: Color = Color("7a2c4c")
const TOWER_BODY: Color = Color("2a2440")
const TOWER_LIGHT: Color = Color("4a4068")
const TOWER_DARK: Color = Color("1a1630")
const WINDOW_OFF: Color = Color("15112a")
const WINDOW_WARM: Color = Color("f0c060")
const WINDOW_RED: Color = Color("e04848")
const CRACK: Color = Color("b060f0")

## Tiers from the ground up: top y, bottom y, width, window columns, window rows.
const TIERS: Array = [
	[232, 296, 80, 6, 4],
	[182, 232, 64, 5, 3],
	[142, 182, 50, 4, 2],
	[116, 142, 36, 3, 2],
]
const SPIRE_TOP: int = 96

var reduced_motion: bool = false

var _time: float = 0.0
var _font: Font
var _stars: Array[Vector3] = []
var _skyline_far: Array[Rect2] = []
var _skyline_near: Array[Rect2] = []
var _embers: Array[Vector3] = []
var _fog: Array[Vector3] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_font = load(PixelTheme.FONT_PATH)
	CharacterSprites.load_sheet("player")
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261028
	for i in STAR_COUNT:
		_stars.append(Vector3(rng.randi_range(0, 479), rng.randi_range(0, HORIZON_Y - 30), rng.randf() * TAU))
	var x := 0
	while x < 480:
		var w := rng.randi_range(14, 30)
		_skyline_far.append(Rect2(x, HORIZON_Y - rng.randi_range(14, 44), w, 80))
		x += w - 2
	x = -6
	while x < 480:
		var w := rng.randi_range(18, 34)
		_skyline_near.append(Rect2(x, HORIZON_Y + 6 - rng.randi_range(8, 36), w, 80))
		x += w
	for i in EMBER_COUNT:
		_embers.append(Vector3(rng.randi_range(TOWER_X - 60, TOWER_X + 60), rng.randf_range(14.0, 34.0), rng.randf() * 200.0))
	for i in FOG_COUNT:
		_fog.append(Vector3(rng.randf_range(-40.0, 480.0), rng.randi_range(0, 2), rng.randf_range(34.0, 80.0)))


func _process(delta: float) -> void:
	if not reduced_motion:
		_time += delta
	queue_redraw()


func _draw() -> void:
	_draw_sky()
	_draw_stars()
	_draw_moon()
	_draw_skyline()
	_draw_tower()
	_draw_ground()
	_draw_player()
	_draw_fog()
	_draw_embers()
	_draw_title()


func _rect(x: float, y: float, w: float, h: float, color: Color) -> void:
	draw_rect(Rect2(floorf(x), floorf(y), w, h), color)


func _hash(a: int, b: int) -> int:
	return absi((a * 73856093) ^ (b * 19349663)) % 100


func _draw_sky() -> void:
	for y in range(0, HORIZON_Y + 4, 4):
		var t := float(y) / float(HORIZON_Y)
		var color := SKY_TOP.lerp(SKY_MID, t * 1.6) if t < 0.625 else SKY_MID.lerp(SKY_LOW, (t - 0.625) / 0.375)
		_rect(0, y, 480, 4, color)


func _draw_stars() -> void:
	for star in _stars:
		var twinkle := 0.5 + 0.5 * sin(_time * 2.2 + star.z)
		var color := Color(0.95, 0.95, 1.0, 0.35 + 0.65 * twinkle)
		_rect(star.x, star.y, 1, 1, color)
		if twinkle > 0.92:
			_rect(star.x - 1, star.y, 3, 1, color)
			_rect(star.x, star.y - 1, 1, 3, color)


func _draw_moon() -> void:
	var centre := Vector2(430, 112)
	for r in [26, 21]:
		for y in range(-r, r + 1):
			var half := int(sqrt(float(r * r - y * y)))
			_rect(centre.x - half, centre.y + y, half * 2, 1, Color(0.9, 0.85, 0.95, 0.06))
	for y in range(-14, 15):
		var half := int(sqrt(float(14 * 14 - y * y)))
		_rect(centre.x - half, centre.y + y, half * 2, 1, Color("ece4f4"))
	for crater in [Vector3(-5, -5, 3), Vector3(4, 2, 4), Vector3(-3, 7, 2)]:
		_rect(centre.x + crater.x, centre.y + crater.y, crater.z, crater.z - 1, Color("c8bcd8"))


func _draw_skyline() -> void:
	for building in _skyline_far:
		_rect(building.position.x, building.position.y, building.size.x, building.size.y, Color("2a1f44"))
		for wy in range(int(building.position.y) + 4, HORIZON_Y, 8):
			for wx in range(int(building.position.x) + 3, int(building.position.x + building.size.x) - 3, 6):
				if _hash(wx, wy) < 18 and _hash(wx + int(_time * 0.7), wy) < 60:
					_rect(wx, wy, 2, 2, Color("6a4a6a"))
	for building in _skyline_near:
		_rect(building.position.x, building.position.y, building.size.x, building.size.y, Color("1a1430"))
		_rect(building.position.x, building.position.y, building.size.x, 1, Color("2e2450"))


func _draw_tower() -> void:
	var glitch := _glitch_active()
	for tier_index in TIERS.size():
		var tier: Array = TIERS[tier_index]
		var top: int = tier[0]
		var bottom: int = tier[1]
		var width: int = tier[2]
		var left := TOWER_X - width / 2
		_rect(left, top, width, bottom - top, TOWER_BODY)
		_rect(left, top, 3, bottom - top, TOWER_DARK)
		_rect(left + width - 4, top, 4, bottom - top, TOWER_LIGHT)
		_rect(left - 4, top, width + 8, 3, TOWER_LIGHT)
		_rect(left - 4, top + 3, width + 8, 2, TOWER_DARK)
		for brick_y in range(top + 9, bottom, 8):
			_rect(left + 3, brick_y, width - 7, 1, Color("231d38"))
		_draw_windows(tier_index, left, top, width, bottom - top, int(tier[3]), int(tier[4]), glitch)
	for y in range(SPIRE_TOP, TIERS[3][0]):
		var progress := y - SPIRE_TOP
		var half := 2 + progress * 7 / (int(TIERS[3][0]) - SPIRE_TOP)
		var lean := (int(TIERS[3][0]) - y) / 7
		_rect(TOWER_X - half + lean, y, half * 2, 1, TOWER_BODY)
		_rect(TOWER_X + half - 2 + lean, y, 2, 1, TOWER_LIGHT)
	var beacon := 0.6 + 0.4 * sin(_time * 3.0)
	for ring in [8, 5, 3]:
		draw_circle(Vector2(TOWER_X + 13, SPIRE_TOP - 3), float(ring), Color(0.95, 0.2, 0.2, 0.10 * beacon * (9 - ring) / 3.0))
	_rect(TOWER_X + 12, SPIRE_TOP - 5, 3, 3, Color(1.0, 0.45 + 0.3 * beacon, 0.4))
	_draw_cracks()
	_draw_door()


func _draw_windows(tier_index: int, left: int, top: int, width: int, height: int, columns: int, rows: int, glitch: bool) -> void:
	var gap_x := (width - 12) / columns
	var gap_y := (height - 14) / rows
	for row in rows:
		for column in columns:
			var wx := left + 8 + column * gap_x + (gap_x - 4) / 2
			var wy := top + 10 + row * gap_y
			var k := tier_index * 100 + row * 10 + column
			var lit := _hash(k, int(_time * 2.0) + k) < 72
			if glitch and _hash(k, 7) < 40:
				lit = not lit
			var corrupt := tier_index >= 2 or _hash(k, 3) < 12 * (tier_index + 1)
			var color := WINDOW_OFF
			if lit:
				color = WINDOW_RED if corrupt else WINDOW_WARM
				_rect(wx - 1, wy - 1, 6, 8, Color(color.r, color.g, color.b, 0.22))
			_rect(wx, wy, 4, 6, color)
			_rect(wx, wy + 3, 4, 1, Color(0, 0, 0, 0.35))


func _draw_cracks() -> void:
	var pulse := 0.55 + 0.45 * sin(_time * 1.7)
	var color := Color(CRACK.r, CRACK.g, CRACK.b, pulse)
	var points := PackedVector2Array([
		Vector2(TOWER_X + 20, 122), Vector2(TOWER_X + 16, 140), Vector2(TOWER_X + 22, 154),
		Vector2(TOWER_X + 15, 172), Vector2(TOWER_X + 21, 190), Vector2(TOWER_X + 12, 214),
		Vector2(TOWER_X + 20, 236), Vector2(TOWER_X + 10, 262), Vector2(TOWER_X + 16, 292),
	])
	draw_polyline(points, Color(color.r, color.g, color.b, pulse * 0.3), 3.0)
	draw_polyline(points, color, 1.0)
	var branch := PackedVector2Array([Vector2(TOWER_X + 21, 190), Vector2(TOWER_X + 28, 198), Vector2(TOWER_X + 26, 208)])
	draw_polyline(branch, color, 1.0)


func _draw_door() -> void:
	var glow := 0.75 + 0.25 * sin(_time * 5.0 + sin(_time * 1.3))
	_rect(TOWER_X - 9, GROUND_Y - 22, 18, 22, Color("120e22"))
	_rect(TOWER_X - 6, GROUND_Y - 26, 12, 4, Color("120e22"))
	_rect(TOWER_X - 6, GROUND_Y - 20, 12, 20, Color(1.0, 0.82 * glow, 0.4 * glow))
	_rect(TOWER_X - 4, GROUND_Y - 23, 8, 3, Color(1.0, 0.82 * glow, 0.4 * glow))
	for step in 3:
		_rect(TOWER_X - 12 - step * 3, GROUND_Y - 1 + step * 2, 24 + step * 6, 2, Color("3a3258"))


func _draw_ground() -> void:
	_rect(0, GROUND_Y, 480, 24, Color("120f1c"))
	_rect(0, GROUND_Y, 480, 1, Color("2e2450"))
	for i in 40:
		_rect((i * 37) % 480, GROUND_Y + 3 + (i * 13) % 18, 2, 1, Color("231d38"))
	for tree_x in [24, 206, 356, 452]:
		_draw_dead_tree(tree_x)


func _draw_dead_tree(x: int) -> void:
	var color := Color("0c0a16")
	_rect(x, GROUND_Y - 28, 3, 29, color)
	draw_line(Vector2(x + 1, GROUND_Y - 18), Vector2(x - 9, GROUND_Y - 30), color, 2.0)
	draw_line(Vector2(x + 2, GROUND_Y - 22), Vector2(x + 11, GROUND_Y - 34), color, 2.0)
	draw_line(Vector2(x - 9, GROUND_Y - 30), Vector2(x - 13, GROUND_Y - 33), color, 1.0)
	draw_line(Vector2(x + 11, GROUND_Y - 34), Vector2(x + 14, GROUND_Y - 40), color, 1.0)


func _draw_player() -> void:
	var bob := 0 if reduced_motion else int(_time * 2.0) % 2
	draw_set_transform(Vector2(TOWER_X - 30, GROUND_Y - 7 + bob * 0), 0.0, Vector2.ONE)
	CharacterSprites.draw_frame(self, "player", "right", 0 if bob == 0 else 1, 16)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_rect(TOWER_X - 36, GROUND_Y + 1, 12, 2, Color(0, 0, 0, 0.35))


func _draw_fog() -> void:
	for puff in _fog:
		var layer := int(puff.y)
		var drift := fposmod(puff.x + _time * (5.0 + layer * 4.0), 560.0) - 60.0
		var y := GROUND_Y - 6 + layer * 8 - 10 * (2 - layer)
		var alpha := 0.07 + 0.03 * layer
		_rect(drift, y, puff.z, 6, Color(0.72, 0.66, 0.85, alpha))
		_rect(drift + 8, y - 3, puff.z - 16, 3, Color(0.72, 0.66, 0.85, alpha * 0.8))
		_rect(drift + 4, y + 6, puff.z - 8, 3, Color(0.72, 0.66, 0.85, alpha * 0.6))


func _draw_embers() -> void:
	for i in _embers.size():
		var ember := _embers[i]
		var rise := fposmod(_time * ember.y + ember.z, 230.0)
		var x := ember.x + sin(_time * 0.9 + float(i)) * 7.0
		var fade := 1.0 - rise / 230.0
		var color := Color(1.0, 0.45 + 0.4 * fade, 0.25, 0.85 * fade)
		_rect(x, GROUND_Y - 4 - rise, 1 + i % 2, 1 + i % 2, color)


func _glitch_active() -> bool:
	return not reduced_motion and fposmod(_time, GLITCH_PERIOD) < GLITCH_LENGTH


func _draw_title() -> void:
	var glitch := _glitch_active()
	var wobble := 0 if reduced_motion else int(round(sin(_time * 1.6) * 1.0))
	_title_line("THE", 20, 31 + wobble, Color("e8c060"), glitch)
	_title_line("CORRUPTED TOWER", 30, 66 + wobble, Color("f8f4ea"), glitch)
	draw_string(_font, Vector2(0, 86), Tr.t("An anti-corruption adventure"), HORIZONTAL_ALIGNMENT_CENTER, 480, 10, Color("b8a8d8"))


## One title line in three layers (drop shadow, red underprint, the text), with colour
## splitting while the title glitches.
func _title_line(text: String, size: int, baseline: int, color: Color, glitch: bool) -> void:
	var offset := Vector2(3, 3)
	draw_string(_font, Vector2(0, baseline) + offset, text, HORIZONTAL_ALIGNMENT_CENTER, 480, size, Color("0a0618"))
	draw_string(_font, Vector2(0, baseline) + Vector2(1, 2), text, HORIZONTAL_ALIGNMENT_CENTER, 480, size, Color("a02840"))
	if glitch:
		draw_string(_font, Vector2(-4, baseline), text, HORIZONTAL_ALIGNMENT_CENTER, 480, size, Color(1.0, 0.2, 0.3, 0.8))
		draw_string(_font, Vector2(4, baseline + 1), text, HORIZONTAL_ALIGNMENT_CENTER, 480, size, Color(0.3, 0.9, 1.0, 0.8))
	draw_string(_font, Vector2(0, baseline), text, HORIZONTAL_ALIGNMENT_CENTER, 480, size, color)
