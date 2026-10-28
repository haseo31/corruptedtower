class_name EvidenceScreen
extends HBoxContainer
## The player's evidence screen: a menu of collected evidence on the left, a description
## box for the focused item on the right, and the fact-check panel beneath it when you
## pick an unverified item. Esc closes the fact-check panel first, then the whole screen.

const EMPTY_TEXT: String = "Nothing yet. Talk to people and check the desks."

var _inventory: EvidenceInventory

@onready var _inventory_panel: InventoryPanel = %InventoryPanel
@onready var _fact_check_panel: FactCheckPanel = %FactCheckPanel
@onready var _description_label: Label = %DescriptionLabel
@onready var _status_label: Label = %StatusLabel


func _ready() -> void:
	PixelTheme.apply(self)


## Connects both panels to an inventory and the fact-check challenges.
func bind(inventory: EvidenceInventory, challenges: Dictionary) -> void:
	if not is_node_ready():
		await ready
	_inventory = inventory
	_inventory_panel.bind(inventory)
	_fact_check_panel.bind(inventory, challenges)
	_inventory_panel.evidence_selected.connect(_fact_check_panel.start)
	_inventory_panel.item_focused.connect(_show_description)
	_inventory.evidence_verified.connect(_show_description)
	_fact_check_panel.visibility_changed.connect(_on_fact_check_visibility_changed)
	_show_description("")


## Shows the screen with the evidence list focused.
func open() -> void:
	show()
	_inventory_panel.open()


func _show_description(evidence_id: String) -> void:
	var item := _inventory.get_item(evidence_id) if _inventory != null else null
	if item == null:
		_description_label.text = EMPTY_TEXT
		_status_label.text = ""
		return
	_description_label.text = item.description
	if item.verified:
		_status_label.text = "Verified."
		_status_label.add_theme_color_override("font_color", PixelTheme.NOTICE)
	else:
		_status_label.text = "Unverified. Press Enter to fact-check it."
		_status_label.add_theme_color_override("font_color", PixelTheme.AMBER)


func _on_fact_check_visibility_changed() -> void:
	if visible and not _fact_check_panel.visible:
		_inventory_panel.focus_list()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		hide()
		get_viewport().set_input_as_handled()
