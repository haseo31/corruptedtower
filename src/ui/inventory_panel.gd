class_name InventoryPanel
extends PanelContainer
## Shows every evidence item the player has collected and whether it is verified.
## It redraws itself from the inventory's signals, so it never keeps a second list.

## Emitted when the player activates (Enter or double-click) an item in the list.
signal evidence_selected(evidence_id: String)

var _inventory: EvidenceInventory

@onready var _item_list: ItemList = %ItemList


func _ready() -> void:
	_item_list.item_activated.connect(_on_item_activated)
	_refresh()


## Connects the panel to an inventory and shows its current contents.
## Safe to call before the panel enters the scene tree.
func bind(inventory: EvidenceInventory) -> void:
	_inventory = inventory
	_inventory.evidence_collected.connect(_on_inventory_changed)
	_inventory.evidence_verified.connect(_on_inventory_changed)
	_refresh()


## Shows the panel, up to date with the inventory, with the first item focused.
func open() -> void:
	_refresh()
	show()
	_item_list.grab_focus()
	if _item_list.item_count > 0:
		_item_list.select(0)


## Gives the list keyboard focus again (for example after a fact-check panel closes).
func focus_list() -> void:
	_item_list.grab_focus()


## Hides the panel.
func close() -> void:
	hide()


func _on_inventory_changed(_evidence_id: String) -> void:
	_refresh()


func _on_item_activated(index: int) -> void:
	evidence_selected.emit(str(_item_list.get_item_metadata(index)))


func _refresh() -> void:
	if not is_node_ready():
		return
	var selected := _item_list.get_selected_items()
	_item_list.clear()
	if _inventory == null:
		return
	for item in _inventory.items():
		var state := "Verified" if item.verified else "Unverified"
		var index := _item_list.add_item("%s  [%s]" % [item.title, state])
		_item_list.set_item_tooltip(index, item.description)
		_item_list.set_item_metadata(index, item.id)
	if not selected.is_empty() and selected[0] < _item_list.item_count:
		_item_list.select(selected[0])
