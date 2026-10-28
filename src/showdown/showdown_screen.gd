class_name ShowdownScreen
extends Control
## The boss showdown, laid out like a monster-catcher battle: the boss on a platform at the
## upper right, the player (back view) at the lower left, the boss's name and Cover-up bar
## at the upper left, a text box with the current lie at the bottom left, and a scrolling
## evidence menu at the bottom right. Keyboard only: arrows and Enter pick evidence, Esc
## leaves. All the rules live in Showdown; this screen only displays them.

## Emitted when the player continues after exposing the boss.
signal showdown_won(boss_id: String)

## When true the boss flash and the screen shake are skipped. A future options menu can set it.
static var reduce_motion: bool = false

const BOSS_FEET: Vector2 = Vector2(350, 100)
const PLAYER_FEET: Vector2 = Vector2(130, 186)
const SHAKE_OFFSETS: Array[Vector2] = [Vector2(3, 0), Vector2(-3, 1), Vector2(2, -1), Vector2(-2, 0)]
const SHAKE_STEP_SECONDS: float = 0.03
const HINT: String = "Evidence marked [?] is unverified and counts as wrong."

var _boss: BossData
var _showdown: Showdown
var _inventory: EvidenceInventory

@onready var _stage: Control = %Stage
@onready var _boss_sprite: BattleSprite = %BossSprite
@onready var _player_sprite: BattleSprite = %PlayerSprite
@onready var _boss_label: Label = %BossLabel
@onready var _cover_up_bar: ProgressBar = %CoverUpBar
@onready var _meter_label: Label = %MeterLabel
@onready var _feedback_label: Label = %FeedbackLabel
@onready var _lie_label: Label = %LieLabel
@onready var _scroll: ScrollContainer = %Scroll
@onready var _buttons_box: VBoxContainer = %ButtonsBox


func _ready() -> void:
	PixelTheme.apply(self)
	_boss_label.add_theme_color_override("font_color", PixelTheme.DANGER)
	_meter_label.add_theme_color_override("font_color", PixelTheme.AMBER)
	_feedback_label.add_theme_color_override("font_color", PixelTheme.SPEAKER)


## Opens a showdown against this boss, presenting evidence from the inventory.
func start(boss: BossData, inventory: EvidenceInventory) -> void:
	_boss = boss
	_inventory = inventory
	_showdown = Showdown.new(boss)
	_boss_label.text = boss.display_name
	_cover_up_bar.max_value = boss.cover_up_max
	_place_sprite(_player_sprite, "player", "up", PLAYER_FEET)
	if boss.sprite.is_empty():
		_boss_sprite.hide()
	else:
		_place_sprite(_boss_sprite, boss.sprite, "down", BOSS_FEET)
	_show_evidence_choices(HINT)
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


func _place_sprite(sprite: BattleSprite, sheet_id: String, direction: String, feet: Vector2) -> void:
	sprite.show_sheet(sheet_id, direction)
	sprite.place(feet, CharacterSprites.frame_size(sheet_id))


func _show_evidence_choices(feedback: String) -> void:
	_clear_buttons()
	_feedback_label.text = feedback
	for item in _inventory.items():
		var button := PixelButton.new()
		button.text = item.title if item.verified else "%s [?]" % item.title
		button.icon = EvidenceIcons.texture_for(item.id)
		button.pressed.connect(_on_evidence_pressed.bind(item.id))
		button.focus_entered.connect(_scroll.ensure_control_visible.bind(button))
		_buttons_box.add_child(button)
	if _buttons_box.get_child_count() == 0:
		_feedback_label.text = "You have no evidence to present."
	_link_menu_focus()
	_update_status()


## Links the menu entries top to bottom by hand. The default arrow-key navigation skips an
## entry that is scrolled completely out of view, which would make it unreachable.
func _link_menu_focus() -> void:
	var buttons := _buttons_box.get_children()
	for index in buttons.size():
		var button := buttons[index] as Button
		var above := buttons[maxi(index - 1, 0)] as Button
		var below := buttons[mini(index + 1, buttons.size() - 1)] as Button
		button.focus_neighbor_top = button.get_path_to(above)
		button.focus_neighbor_bottom = button.get_path_to(below)
		button.focus_neighbor_left = button.get_path_to(button)
		button.focus_neighbor_right = button.get_path_to(button)


func _on_evidence_pressed(evidence_id: String) -> void:
	var result := _showdown.present_from(_inventory, evidence_id)
	_update_status()
	if result == Showdown.Result.COUNTERED:
		_flash_boss()
	else:
		_shake()
	if _showdown.state == Showdown.State.WON:
		_show_end("The cover-up collapses. You exposed %s." % _boss.display_name, "Continue", _on_continue)
	elif _showdown.state == Showdown.State.LOST:
		_show_end("The cover-up holds. Verify more evidence, then try again.", "Try again", _on_retry)
	elif result == Showdown.Result.COUNTERED:
		_feedback_label.text = "That exposes the lie."
	else:
		_feedback_label.text = "That does not hold up. Only verified evidence counts."


func _show_end(message: String, button_text: String, callback: Callable) -> void:
	_clear_buttons()
	_feedback_label.text = message
	var button := PixelButton.new()
	button.text = button_text
	button.pressed.connect(callback)
	_buttons_box.add_child(button)
	_focus_first_button()


func _on_continue() -> void:
	hide()
	showdown_won.emit(_boss.id)


func _on_retry() -> void:
	_showdown.restart()
	_show_evidence_choices(HINT)
	_focus_first_button()


func _update_status() -> void:
	var lie := _showdown.current_lie()
	_lie_label.text = "" if lie == null else "\"%s\"" % lie.text
	_lie_label.visible = lie != null
	_cover_up_bar.value = _showdown.cover_up
	_meter_label.text = "Cover-up %d / %d" % [_showdown.cover_up, _boss.cover_up_max]


func _flash_boss() -> void:
	if not reduce_motion and _boss_sprite.visible:
		_boss_sprite.flash()


func _shake() -> void:
	if reduce_motion:
		return
	var tween := create_tween()
	for offset in SHAKE_OFFSETS:
		tween.tween_property(_stage, "position", offset, SHAKE_STEP_SECONDS)
	tween.tween_property(_stage, "position", Vector2.ZERO, SHAKE_STEP_SECONDS)


func _clear_buttons() -> void:
	for child in _buttons_box.get_children():
		_buttons_box.remove_child(child)
		child.queue_free()


func _focus_first_button() -> void:
	if _buttons_box.get_child_count() > 0:
		(_buttons_box.get_child(0) as Button).grab_focus()
