class_name DialogueBox
extends PanelContainer
## Shows a conversation at the bottom of the screen: who is speaking, the current line,
## and one button per choice. Keyboard only: the interact key advances a line, arrows
## and Enter pick a choice. It only displays; DialogueRunner owns the conversation.

var _runner: DialogueRunner
var _inventory: EvidenceInventory

@onready var _speaker_label: Label = %SpeakerLabel
@onready var _text_label: Label = %TextLabel
@onready var _choices_box: VBoxContainer = %ChoicesBox
@onready var _notice_label: Label = %NoticeLabel


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


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _runner == null or _runner.is_choosing():
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_runner.advance()


func _on_line_changed(speaker: String, text: String) -> void:
	_clear_choices()
	_speaker_label.text = speaker
	_speaker_label.visible = not speaker.is_empty()
	_text_label.text = text
	show()


func _on_choices_shown(choices: Array) -> void:
	_clear_choices()
	for index in choices.size():
		var button := Button.new()
		button.text = str(choices[index])
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_on_choice_pressed.bind(index))
		_choices_box.add_child(button)
	(_choices_box.get_child(0) as Button).grab_focus()


func _on_choice_pressed(index: int) -> void:
	_runner.choose(index)


func _on_evidence_granted(evidence_id: String) -> void:
	var item := _inventory.get_item(evidence_id)
	_notice_label.text = "+ Evidence: %s" % item.title
	_notice_label.show()


func _on_finished() -> void:
	_clear_choices()
	_notice_label.hide()
	hide()


func _clear_choices() -> void:
	for child in _choices_box.get_children():
		_choices_box.remove_child(child)
		child.queue_free()
