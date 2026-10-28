class_name FactCheckPanel
extends VBoxContainer
## Shows one fact-check challenge like a conversation: a question box with the claim (and
## the feedback after each answer) above a choices menu with one entry per source. The
## player picks the fake or unreliable one. Keyboard only: arrows move, Enter picks, Esc
## closes. All answer logic lives in FactCheckSession; this panel only displays it.

signal challenge_completed(evidence_id: String)

var _session: FactCheckSession
var _challenges: Dictionary = {}

@onready var _claim_label: Label = %ClaimLabel
@onready var _options_box: VBoxContainer = %OptionsBox
@onready var _feedback_label: Label = %FeedbackLabel


func _ready() -> void:
	_feedback_label.add_theme_color_override("font_color", PixelTheme.SPEAKER)


## Connects the panel to an inventory and a set of challenges (evidence id -> FactCheckChallenge).
func bind(inventory: EvidenceInventory, challenges: Dictionary) -> void:
	_session = FactCheckSession.new(inventory)
	_challenges = challenges


## Shows the challenge for this evidence. Returns false if it cannot start
## (not collected, already verified, or no challenge exists for it).
func start(evidence_id: String) -> bool:
	if _session == null or not _session.start(evidence_id, _challenges):
		return false
	var challenge := _session.challenge
	_claim_label.text = challenge.claim
	_feedback_label.text = ""
	for child in _options_box.get_children():
		_options_box.remove_child(child)
		child.queue_free()
	for index in challenge.options.size():
		var button := PixelButton.new()
		button.text = challenge.options[index]
		button.pressed.connect(_on_option_pressed.bind(index))
		_options_box.add_child(button)
	show()
	(_options_box.get_child(0) as Button).grab_focus()
	return true


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		hide()
		get_viewport().set_input_as_handled()


func _on_option_pressed(option_index: int) -> void:
	var result := _session.submit(option_index)
	var challenge := _session.challenge
	if result == FactCheckSession.Result.CORRECT:
		Audio.play_sfx("correct")
		_feedback_label.text = "Verified. " + challenge.explanation
		for child in _options_box.get_children():
			(child as Button).disabled = true
		challenge_completed.emit(challenge.evidence_id)
	elif result == FactCheckSession.Result.WRONG:
		Audio.play_sfx("wrong")
		_feedback_label.text = "Not that one, try again. " + challenge.explanation
