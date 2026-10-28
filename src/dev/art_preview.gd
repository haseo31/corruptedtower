extends Node2D
## Dev-only preview of the generated pixel art (tiles, characters, font). Run this scene
## directly to check the output of tools/art/generate_art.py. Not part of the game.

const CHARACTERS: Array[String] = ["player", "clerk", "janitor", "archivist", "intern"]
const BOSSES: Array[String] = ["deputy_director", "spokesperson"]
const BOSS_SIZE: int = 24
const CHAR_W: int = 16
const CHAR_H: int = 20
const TILE: int = 16
const VIEW: Vector2 = Vector2(480, 320)

var _tiles: Texture2D
var _font: Font
var _sheets: Dictionary = {}


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_tiles = load("res://assets/art/tiles.png")
	_font = load("res://assets/art/font_pixel.fnt")
	for name in CHARACTERS + BOSSES:
		_sheets[name] = load("res://assets/art/char_%s.png" % name)
	scale = Vector2(2, 2)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color("2b2e3a"))
	_label("TILES", Vector2(8, 16), Color.WHITE)
	for i in 8:
		draw_texture_rect_region(_tiles, Rect2(8 + i * 20, 22, TILE, TILE), Rect2(i * TILE, 0, TILE, TILE))
	_label("PLAYER: DOWN, UP, LEFT, RIGHT, WALK", Vector2(8, 52), Color.WHITE)
	var player: Texture2D = _sheets["player"]
	for row in 4:
		_frame(player, 0, row, Vector2(8 + row * 24, 58))
	for k in 3:
		var column: int = [1, 0, 2][k]
		_frame(player, column, 0, Vector2(112 + k * 24, 58))
	_label("CAST", Vector2(8, 90), Color.WHITE)
	for i in CHARACTERS.size():
		var sheet: Texture2D = _sheets[CHARACTERS[i]]
		_frame(sheet, 0, 0, Vector2(8 + i * 36, 96))
		_frame(sheet, 0, 2, Vector2(26 + i * 36, 96))
	for i in BOSSES.size():
		var sheet: Texture2D = _sheets[BOSSES[i]]
		for frame in 2:
			var at := Vector2(200 + i * 60 + frame * 26, 92)
			draw_texture_rect_region(sheet, Rect2(at, Vector2(BOSS_SIZE, BOSS_SIZE)),
					Rect2(frame * BOSS_SIZE, 0, BOSS_SIZE, BOSS_SIZE))
	var box := Rect2(8, 128, 464, 120)
	draw_rect(box, Color.WHITE)
	draw_rect(box, Color("2b2233"), false, 2.0)
	var ink := Color("2b2233")
	_label("The quick brown fox jumps over the lazy dog.", Vector2(16, 142), ink)
	_label("THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG", Vector2(16, 156), ink)
	_label("0123456789 !?.,:;'\"-+=()/%#&*<>_[]", Vector2(16, 170), ink)
	_label("▶ Ask about the road project budget", Vector2(16, 188), ink)
	_label("Cover-up: 2 / 3   +Evidence: Ledger page  ▼", Vector2(16, 204), ink)
	_label("Jumpy wizards quickly vex the big dog.  gjpqy", Vector2(16, 222), ink)


func _frame(sheet: Texture2D, column: int, row: int, at: Vector2) -> void:
	draw_texture_rect_region(sheet, Rect2(at, Vector2(CHAR_W, CHAR_H)),
			Rect2(column * CHAR_W, row * CHAR_H, CHAR_W, CHAR_H))


func _label(text: String, baseline: Vector2, color: Color) -> void:
	draw_string(_font, baseline, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, color)
