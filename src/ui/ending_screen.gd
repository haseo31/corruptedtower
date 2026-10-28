class_name EndingScreen
extends Control
## The single ending: shown when the last boss is exposed. It reports how much evidence
## the player verified out of everything in the game, shows the player with the two bosses
## they exposed, and offers a new run.

const FIRST_FLOOR: String = "res://src/world/floor_1.tscn"

const CAST_FEET_Y: float = 304.0

@onready var _deputy_sprite: BattleSprite = %DeputySprite
@onready var _player_sprite: BattleSprite = %PlayerSprite
@onready var _spokesperson_sprite: BattleSprite = %SpokespersonSprite
@onready var _title_label: Label = %Title
@onready var _score_label: Label = %ScoreLabel
@onready var _restart_button: Button = %RestartButton


func _ready() -> void:
	PixelTheme.apply(self)
	_title_label.add_theme_color_override("font_color", PixelTheme.DANGER)
	_score_label.add_theme_color_override("font_color", PixelTheme.NOTICE)
	var inventory := GameSession.inventory()
	_score_label.text = "Evidence verified: %d of %d" % [inventory.verified_count(), inventory.catalog_size()]
	_restart_button.pressed.connect(_on_restart_pressed)
	_restart_button.grab_focus()
	_place_cast(_deputy_sprite, "deputy_director", 150.0)
	_place_cast(_player_sprite, "player", 240.0)
	_place_cast(_spokesperson_sprite, "spokesperson", 330.0)


## Puts a character from the story on the ground strip, standing at this x position.
func _place_cast(sprite: BattleSprite, sheet_id: String, x: float) -> void:
	sprite.show_sheet(sheet_id, "down")
	sprite.place(Vector2(x, CAST_FEET_Y), CharacterSprites.frame_size(sheet_id))


func _on_restart_pressed() -> void:
	GameSession.reset()
	FloorScene.arrival_cell = null
	get_tree().change_scene_to_file(FIRST_FLOOR)
