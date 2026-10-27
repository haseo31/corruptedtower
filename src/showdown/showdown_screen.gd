class_name ShowdownScreen
extends PanelContainer
## The boss showdown on screen: the boss, its current lie, the Cover-up meter, and one
## button per piece of collected evidence. Keyboard only: arrows and Enter pick evidence,
## Esc leaves. All the rules live in Showdown; this panel only displays them.

## Emitted when the player continues after exposing the boss.
signal showdown_won(boss_id: String)

var _boss: BossData
var _showdown: Showdown
var _inventory: EvidenceInventory

@onready var _boss_label: Label = %BossLabel
@onready var _lie_label: Label = %LieLabel
@onready var _meter_label: Label = %MeterLabel
@onready var _buttons_box: VBoxContainer = %ButtonsBox
@onready var _feedback_label: Label = %FeedbackLabel


## Opens a showdown against this boss, presenting evidence from the inventory.
func start(boss: BossData, inventory: EvidenceInventory) -> void:
	_boss = boss
	_inventory = inventory
	_showdown = Showdown.new(boss)
	_boss_label.text = boss.display_name
	_show_evidence_choices("")
	show()
	_focus_first_button()


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not event.is_action_pressed("ui_cancel"):
		return
	get_viewport().set_input_as_handled()
	if _showdown.state == Showdown.State.WON:
		_on_continue()
	else:
		hide()


func _show_evidence_choices(feedback: String) -> void:
	_clear_buttons()
	_feedback_label.text = feedback
	for item in _inventory.items():
		var state := "Verified" if item.verified else "Unverified"
		var button := Button.new()
		button.text = "%s  [%s]" % [item.title, state]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_on_evidence_pressed.bind(item.id))
		_buttons_box.add_child(button)
	if _buttons_box.get_child_count() == 0:
		_feedback_label.text = "You have no evidence to present."
	_update_status()


func _on_evidence_pressed(evidence_id: String) -> void:
	var result := _showdown.present_from(_inventory, evidence_id)
	var feedback := ""
	if result == Showdown.Result.COUNTERED:
		feedback = "That exposes the lie."
	elif result == Showdown.Result.WRONG_EVIDENCE:
		feedback = "That does not hold up, and only verified evidence counts. The Cover-up grows."
	_update_status()
	if _showdown.state == Showdown.State.WON:
		_show_end("The cover-up collapses. You exposed %s." % _boss.display_name, "Continue", _on_continue)
	elif _showdown.state == Showdown.State.LOST:
		_show_end("The cover-up holds. Verify more evidence, then try again.", "Try again", _on_retry)
	else:
		_feedback_label.text = feedback


func _show_end(message: String, button_text: String, callback: Callable) -> void:
	_clear_buttons()
	_feedback_label.text = message
	var button := Button.new()
	button.text = button_text
	button.pressed.connect(callback)
	_buttons_box.add_child(button)
	_focus_first_button()


func _on_continue() -> void:
	hide()
	showdown_won.emit(_boss.id)


func _on_retry() -> void:
	_showdown.restart()
	_show_evidence_choices("")
	_focus_first_button()


func _update_status() -> void:
	var lie := _showdown.current_lie()
	_lie_label.text = "" if lie == null else "\"%s\"" % lie.text
	_meter_label.text = "Cover-up: %d / %d" % [_showdown.cover_up, _boss.cover_up_max]


func _clear_buttons() -> void:
	for child in _buttons_box.get_children():
		_buttons_box.remove_child(child)
		child.queue_free()


func _focus_first_button() -> void:
	if _buttons_box.get_child_count() > 0:
		(_buttons_box.get_child(0) as Button).grab_focus()
