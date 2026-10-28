class_name InventoryPanel
extends PanelContainer
## The player's collected evidence as a menu: one entry per item with its icon, name and
## an arrow on the focused entry. It rebuilds from the inventory's signals, so it never
## keeps a second list, and it keeps the focused item across a rebuild.

## Emitted when the player picks an entry (Enter).
signal evidence_selected(evidence_id: String)
## Emitted when an entry gains keyboard focus, so a description can follow it.
signal item_focused(evidence_id: String)

var _inventory: EvidenceInventory
var _last_focused: String = ""

@onready var _items_box: VBoxContainer = %ItemsBox


func _ready() -> void:
	Tr.apply(self)
	_refresh()


## Connects the panel to an inventory and shows its current contents.
## Safe to call before the panel enters the scene tree.
func bind(inventory: EvidenceInventory) -> void:
	_inventory = inventory
	_inventory.evidence_collected.connect(_on_inventory_changed)
	_inventory.evidence_verified.connect(_on_inventory_changed)
	_refresh()


## Shows the panel, up to date with the inventory, with an entry focused.
func open() -> void:
	_refresh()
	show()
	focus_list()


## Gives focus back to the entry that had it last (or the first), for example after a
## fact-check panel closes.
func focus_list() -> void:
	var target := _button_for(_last_focused)
	if target == null and _items_box.get_child_count() > 0:
		target = _items_box.get_child(0) as Button
	if target != null:
		target.grab_focus()


## Hides the panel.
func close() -> void:
	hide()


func _on_inventory_changed(_evidence_id: String) -> void:
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return
	var had_focus := _list_has_focus()
	for child in _items_box.get_children():
		_items_box.remove_child(child)
		child.queue_free()
	if _inventory == null:
		return
	for item in _inventory.items():
		var button := PixelButton.new()
		button.text = item.title if item.verified else "%s [?]" % item.title
		button.icon = EvidenceIcons.texture_for(item.id)
		button.pressed.connect(_on_item_pressed.bind(item.id))
		button.focus_entered.connect(_on_item_focus_entered.bind(item.id))
		_items_box.add_child(button)
	if had_focus:
		focus_list()


func _on_item_pressed(evidence_id: String) -> void:
	evidence_selected.emit(evidence_id)


func _on_item_focus_entered(evidence_id: String) -> void:
	_last_focused = evidence_id
	item_focused.emit(evidence_id)


func _list_has_focus() -> bool:
	for child in _items_box.get_children():
		if (child as Control).has_focus():
			return true
	return false


func _button_for(evidence_id: String) -> Button:
	if _inventory == null or evidence_id.is_empty():
		return null
	var items := _inventory.items()
	for index in items.size():
		if items[index].id == evidence_id and index < _items_box.get_child_count():
			return _items_box.get_child(index) as Button
	return null
