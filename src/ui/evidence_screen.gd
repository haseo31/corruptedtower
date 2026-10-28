class_name EvidenceScreen
extends HBoxContainer
## The player's evidence screen: the inventory list beside the fact-check panel.
## Activating an unverified item in the list opens its fact-check challenge.
## Esc closes the fact-check panel first, then the whole screen.

@onready var _inventory_panel: InventoryPanel = %InventoryPanel
@onready var _fact_check_panel: FactCheckPanel = %FactCheckPanel


func _ready() -> void:
	PixelTheme.apply(self)


## Connects both panels to an inventory and the fact-check challenges.
func bind(inventory: EvidenceInventory, challenges: Dictionary) -> void:
	if not is_node_ready():
		await ready
	_inventory_panel.bind(inventory)
	_fact_check_panel.bind(inventory, challenges)
	_inventory_panel.evidence_selected.connect(_fact_check_panel.start)
	_fact_check_panel.visibility_changed.connect(_on_fact_check_visibility_changed)


## Shows the screen with the evidence list focused.
func open() -> void:
	show()
	_inventory_panel.open()


func _on_fact_check_visibility_changed() -> void:
	if visible and not _fact_check_panel.visible:
		_inventory_panel.focus_list()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		hide()
		get_viewport().set_input_as_handled()
