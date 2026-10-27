class_name EndingScreen
extends Control
## The single ending: shown when the last boss is exposed. It reports how much evidence
## the player verified out of everything in the game, and offers a new run.

const FIRST_FLOOR: String = "res://src/world/floor_1.tscn"

@onready var _score_label: Label = %ScoreLabel
@onready var _restart_button: Button = %RestartButton


func _ready() -> void:
	var inventory := GameSession.inventory()
	_score_label.text = "Evidence verified: %d of %d" % [inventory.verified_count(), inventory.catalog_size()]
	_restart_button.pressed.connect(_on_restart_pressed)
	_restart_button.grab_focus()


func _on_restart_pressed() -> void:
	GameSession.reset()
	FloorScene.arrival_cell = null
	get_tree().change_scene_to_file(FIRST_FLOOR)
