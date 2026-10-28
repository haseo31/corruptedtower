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
	Tr.apply(self)
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
	_show_evidence_choices(Tr.t(HINT) if boss.intro.is_empty() else "\"%s\"\n%s" % [boss.intro, Tr.t(HINT)])
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
		_feedback_label.text = Tr.t("You have no evidence to present.")
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
	var proofs_before := _showdown.lie_progress().x
	var result := _showdown.present_from(_inventory, evidence_id)
	# A piece of proof already presented for this lie is not a new right choice.
	if result == Showdown.Result.COUNTERED or (result == Showdown.Result.PROGRESS and _showdown.lie_progress().x > proofs_before):
		GameSession.record_choice(true)
	elif result == Showdown.Result.WRONG_EVIDENCE:
		GameSession.record_choice(false)
	_update_status()
	if result == Showdown.Result.COUNTERED:
		Audio.play_sfx("counter")
		_flash_boss()
	elif result == Showdown.Result.PROGRESS:
		Audio.play_sfx("correct")
	else:
		Audio.play_sfx("wrong")
		_shake()
	if _showdown.state == Showdown.State.WON:
		Audio.play_sfx("win")
		var last_words := _reaction_for_last_counter()
		_show_end(Tr.t("%sThe cover-up collapses. You exposed %s.") % ["" if last_words.is_empty() else last_words + "
", _boss.display_name],
				Tr.t("Continue"), _on_continue)
	elif _showdown.state == Showdown.State.LOST:
		Audio.play_sfx("lose")
		_show_end(Tr.t("The cover-up holds. Verify more evidence, then try again."), Tr.t("Try again"), _on_retry)
	elif result == Showdown.Result.COUNTERED:
		var reaction := _reaction_for_last_counter()
		_feedback_label.text = Tr.t("That exposes the lie.") if reaction.is_empty() else Tr.t("That exposes the lie.") + " " + reaction
	elif result == Showdown.Result.PROGRESS:
		_feedback_label.text = Tr.t("That is part of the answer. This lie needs more than one piece of proof.")
	else:
		_feedback_label.text = Tr.t("That does not hold up. Only verified evidence counts.")


## What the boss admits about the lie just countered; a shortcut item gets its own line.
func _reaction_for_last_counter() -> String:
	var lie := _showdown.last_countered
	if lie == null:
		return ""
	var is_shortcut := not lie.counter_all_ids.is_empty() and _showdown.last_countered_by in lie.counter_evidence_ids
	return lie.shortcut_reaction if is_shortcut and not lie.shortcut_reaction.is_empty() else lie.reaction


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
	var progress := _showdown.lie_progress()
	var needs_several := progress.y > 1
	_lie_label.text = "" if lie == null else "\"%s\"%s" % [lie.text, Tr.t("  (proof %d of %d)") % [progress.x, progress.y] if needs_several else ""]
	_lie_label.visible = lie != null
	_cover_up_bar.value = _showdown.cover_up
	_meter_label.text = Tr.t("Cover-up %d / %d") % [_showdown.cover_up, _boss.cover_up_max]


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
