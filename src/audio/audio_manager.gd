extends Node
## The game's sound: one autoload named Audio. Music tracks crossfade and loop on the "Music"
## bus; effects play on the "SFX" bus from a small pool. Both buses take their volume from
## GameSettings. A missing file is silently skipped, so the game runs without any audio.
##
## Use:  Audio.play_music("title")   Audio.play_sfx("ui_select")   Audio.stop_music()

const MUSIC_DIR: String = "res://assets/audio/music/"
const SFX_DIR: String = "res://assets/audio/sfx/"
const MUSIC_EXTENSIONS: Array = ["ogg", "mp3", "wav"]
const SFX_VOICES: int = 8
const FADE_SECONDS: float = 0.8
const SILENT_DB: float = -60.0
## Effects that may only fire this often (seconds), so held keys do not buzz.
const MIN_GAP: float = 0.04

var current_music: String = ""

var _sfx_cache: Dictionary = {}
var _music_cache: Dictionary = {}
var _voices: Array[AudioStreamPlayer] = []
var _next_voice: int = 0
var _music_a: AudioStreamPlayer
var _music_b: AudioStreamPlayer
var _active: AudioStreamPlayer
var _last_played: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameSettings.load_and_apply()
	for i in SFX_VOICES:
		var voice := AudioStreamPlayer.new()
		voice.bus = GameSettings.SFX_BUS
		add_child(voice)
		_voices.append(voice)
	_music_a = _make_music_player()
	_music_b = _make_music_player()
	_active = _music_a


## Plays a sound effect by file name (assets/audio/sfx/<name>.wav).
func play_sfx(sfx_name: String) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if now - float(_last_played.get(sfx_name, -1.0)) < MIN_GAP:
		return
	_last_played[sfx_name] = now
	var stream := _load_sfx(sfx_name)
	if stream == null:
		return
	var voice := _voices[_next_voice]
	_next_voice = (_next_voice + 1) % _voices.size()
	voice.stream = stream
	voice.play()


## Starts a looping music track by name (assets/audio/music/<name>.ogg, .mp3 or .wav),
## crossfading from the one playing. The same track again does nothing.
func play_music(track: String) -> void:
	if track == current_music:
		return
	current_music = track
	var stream := _load_music(track)
	var outgoing := _active
	_active = _music_b if _active == _music_a else _music_a
	_fade(outgoing, SILENT_DB, true)
	if stream == null:
		return
	_active.stream = stream
	_active.volume_db = SILENT_DB
	_active.play()
	_fade(_active, 0.0, false)


## Fades the music out.
func stop_music() -> void:
	current_music = ""
	_fade(_active, SILENT_DB, true)


func _make_music_player() -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = GameSettings.MUSIC_BUS
	player.volume_db = SILENT_DB
	add_child(player)
	return player


func _fade(player: AudioStreamPlayer, to_db: float, stop_after: bool) -> void:
	if not player.playing and stop_after:
		return
	var tween := create_tween()
	tween.tween_property(player, "volume_db", to_db, FADE_SECONDS)
	if stop_after:
		tween.tween_callback(func() -> void:
			if player != _active:
				player.stop())


func _load_sfx(sfx_name: String) -> AudioStream:
	if not _sfx_cache.has(sfx_name):
		var path := "%s%s.wav" % [SFX_DIR, sfx_name]
		_sfx_cache[sfx_name] = load(path) if ResourceLoader.exists(path) else null
	return _sfx_cache[sfx_name]


func _load_music(track: String) -> AudioStream:
	if not _music_cache.has(track):
		var stream: AudioStream = null
		for extension: String in MUSIC_EXTENSIONS:
			var path := "%s%s.%s" % [MUSIC_DIR, track, extension]
			if ResourceLoader.exists(path):
				stream = load(path)
				break
		if stream != null and "loop" in stream:
			stream.loop = true
		_music_cache[track] = stream
	return _music_cache[track]
