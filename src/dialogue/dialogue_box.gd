class_name DialogueBox
extends Control
## Shows a conversation Pokémon-style: a bordered text box along the bottom with the
## speaker's name above the line, which types out one character at a time, and a
## separate choices menu above it on the right. Interact shows the whole line at once,
## then moves on; a blinking arrow shows when a line is complete. It only displays;
## DialogueRunner owns the conversation.

## Characters revealed per second. Static so one setting covers every floor; a future
## options menu can change it, and tests set it very high to skip the typing.
static var text_speed: float = 45.0
## A text blip sounds once per this many revealed characters.
const BLIP_EVERY: int = 3

const ARROW: String = "▼"
const ARROW_BLINK_SECONDS: float = 0.4

var _runner: DialogueRunner
var _inventory: EvidenceInventory
var _revealed: float = 0.0
var _line_length: int = 0
var _line_complete: bool = true
var _blink_time: float = 0.0

@onready var _choices_panel: PanelContainer = %ChoicesPanel
@onready var _speaker_label: Label = %SpeakerLabel
@onready var _text_label: Label = %TextLabel
@onready var _choices_box: VBoxContainer = %ChoicesBox
@onready var _notice_label: Label = %NoticeLabel
@onready var _arrow_label: Label = %ArrowLabel


func _ready() -> void:
	PixelTheme.apply(self)
	_arrow_label.text = ARROW
	_arrow_label.hide()
	_speaker_label.add_theme_color_override("font_color", PixelTheme.SPEAKER)
	_notice_label.add_theme_color_override("font_color", PixelTheme.NOTICE)


## Connects the box to a runner; the inventory is read only to name collected evidence.
func bind(runner: DialogueRunner, inventory: EvidenceInventory) -> void:
	_runner = runner
	_inventory = inventory
	runner.line_changed.connect(_on_line_changed)
	runner.choices_shown.connect(_on_choices_shown)
	runner.evidence_granted.connect(_on_evidence_granted)
	runner.finished.connect(_on_finished)


## True while a conversation is on screen.
func is_open() -> bool:
	return visible


func _process(delta: float) -> void:
	if not visible:
		return
	if not _line_complete:
		_revealed += delta * text_speed
		var shown := int(_revealed)
		if shown / BLIP_EVERY != _text_label.visible_characters / BLIP_EVERY:
			Audio.play_sfx("blip")
		_text_label.visible_characters = shown
		if int(_revealed) >= _line_length:
			_finish_line()
	elif _arrow_label.visible:
		_blink_time += delta
		_arrow_label.modulate.a = 1.0 if fmod(_blink_time, ARROW_BLINK_SECONDS * 2.0) < ARROW_BLINK_SECONDS else 0.0


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _runner == null or _runner.is_choosing():
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		if _line_complete:
			_runner.advance()
		else:
			_finish_line()


func _finish_line() -> void:
	_line_complete = true
	_text_label.visible_characters = -1
	_blink_time = 0.0
	_arrow_label.modulate.a = 1.0
	_arrow_label.visible = not _runner.is_choosing()


func _on_line_changed(speaker: String, text: String) -> void:
	_clear_choices()
	_speaker_label.text = speaker
	_speaker_label.visible = not speaker.is_empty()
	_text_label.text = text
	_text_label.visible_characters = 0
	_line_length = text.length()
	_revealed = 0.0
	_line_complete = false
	_arrow_label.hide()
	show()


func _on_choices_shown(choices: Array) -> void:
	_clear_choices()
	_arrow_label.hide()
	for index in choices.size():
		var button := PixelButton.new()
		button.text = str(choices[index])
		button.pressed.connect(_on_choice_pressed.bind(index))
		_choices_box.add_child(button)
	_choices_panel.show()
	(_choices_box.get_child(0) as Button).grab_focus()


func _on_choice_pressed(index: int) -> void:
	_runner.choose(index)


func _on_evidence_granted(evidence_id: String) -> void:
	var item := _inventory.get_item(evidence_id)
	_notice_label.text = Tr.t("+ Evidence: %s") % item.title
	_notice_label.show()


func _on_finished() -> void:
	_clear_choices()
	_notice_label.hide()
	_arrow_label.hide()
	hide()


func _clear_choices() -> void:
	_choices_panel.hide()
	for child in _choices_box.get_children():
		_choices_box.remove_child(child)
		child.queue_free()
