class_name GameSettings
extends RefCounted
## The player's options: window mode and size, music and effects volume, text speed and
## reduced motion. They live in one small JSON file (user://settings.json), are checked
## when read (a missing or damaged file gives the defaults), and are applied to the window,
## the audio buses and the two static switches the dialogue and showdown screens read.

const VERSION: int = 1
const MAX_SCALE: int = 4
const MAX_VOLUME: int = 10
const BASE_SIZE: Vector2i = Vector2i(480, 320)
const MUSIC_BUS: String = "Music"
const SFX_BUS: String = "SFX"
## Name, characters revealed per second.
const TEXT_SPEEDS: Array = [["Slow", 25.0], ["Normal", 45.0], ["Fast", 90.0]]

## Where the settings live. Static so tests can point it at a scratch file.
static var save_path: String = "user://settings.json"

static var fullscreen: bool = false
## Window size as a multiple of the 480x320 game screen (windowed mode).
static var window_scale: int = 2
static var music_volume: int = 7
static var sfx_volume: int = 8
## Index into TEXT_SPEEDS.
static var text_speed_index: int = 1
static var reduce_motion: bool = false


## Puts every option back to its default.
static func reset_to_defaults() -> void:
	fullscreen = false
	window_scale = 2
	music_volume = 7
	sfx_volume = 8
	text_speed_index = 1
	reduce_motion = false


## Reads the settings file (if any), then applies everything. Call once at start-up.
static func load_and_apply() -> void:
	reset_to_defaults()
	if FileAccess.file_exists(save_path):
		var json := JSON.new()
		if json.parse(FileAccess.get_file_as_string(save_path)) == OK and json.data is Dictionary:
			_take(json.data)
	apply()


## Writes the settings file. Returns false (and logs why) if it cannot.
static func save() -> bool:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_error("GameSettings: cannot write %s (error %d)" % [save_path, FileAccess.get_open_error()])
		return false
	file.store_string(JSON.stringify({
		"version": VERSION,
		"fullscreen": fullscreen,
		"window_scale": window_scale,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"text_speed_index": text_speed_index,
		"reduce_motion": reduce_motion,
	}, "\t"))
	return true


## Applies the options to the running game.
static func apply() -> void:
	DialogueBox.text_speed = float(TEXT_SPEEDS[text_speed_index][1])
	ShowdownScreen.reduce_motion = reduce_motion
	_ensure_bus(MUSIC_BUS)
	_ensure_bus(SFX_BUS)
	_set_bus_volume(MUSIC_BUS, music_volume)
	_set_bus_volume(SFX_BUS, sfx_volume)
	_apply_window()


## The window size, in pixels, for a scale (what the Settings screen shows).
static func window_size_for(scale: int) -> Vector2i:
	return BASE_SIZE * scale


## The largest scale that fits the screen the window is on (at least 1).
static func largest_scale_that_fits() -> int:
	if DisplayServer.get_name() == "headless":
		return MAX_SCALE
	var usable := DisplayServer.screen_get_usable_rect(DisplayServer.window_get_current_screen()).size
	var fit := 1
	for scale in range(1, MAX_SCALE + 1):
		if window_size_for(scale).x <= usable.x and window_size_for(scale).y <= usable.y:
			fit = scale
	return fit


## The display name of the current text speed.
static func text_speed_name() -> String:
	return TEXT_SPEEDS[text_speed_index][0]


static func _take(data: Dictionary) -> void:
	if int(data.get("version", -1)) != VERSION:
		return
	if data.get("fullscreen") is bool:
		fullscreen = data["fullscreen"]
	if data.get("window_scale") is float:
		window_scale = clampi(int(data["window_scale"]), 1, MAX_SCALE)
	if data.get("music_volume") is float:
		music_volume = clampi(int(data["music_volume"]), 0, MAX_VOLUME)
	if data.get("sfx_volume") is float:
		sfx_volume = clampi(int(data["sfx_volume"]), 0, MAX_VOLUME)
	if data.get("text_speed_index") is float:
		text_speed_index = clampi(int(data["text_speed_index"]), 0, TEXT_SPEEDS.size() - 1)
	if data.get("reduce_motion") is bool:
		reduce_motion = data["reduce_motion"]


static func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)


static func _set_bus_volume(bus_name: String, volume: int) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index == -1:
		return
	AudioServer.set_bus_mute(index, volume == 0)
	AudioServer.set_bus_volume_db(index, linear_to_db(float(volume) / MAX_VOLUME) if volume > 0 else -80.0)


static func _apply_window() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	var scale := mini(window_scale, largest_scale_that_fits())
	var size := window_size_for(scale)
	DisplayServer.window_set_size(size)
	var screen := DisplayServer.window_get_current_screen()
	var usable := DisplayServer.screen_get_usable_rect(screen)
	DisplayServer.window_set_position(usable.position + (usable.size - size) / 2)
