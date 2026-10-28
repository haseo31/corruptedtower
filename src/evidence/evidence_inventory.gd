class_name EvidenceInventory
extends RefCounted
## The player's collected evidence. Built from a catalog of evidence definitions;
## owns what the player has collected and which items are verified. The showdown
## reads it but never owns evidence, so a lost showdown keeps everything collected.

signal evidence_collected(evidence_id: String)
signal evidence_verified(evidence_id: String)

## Evidence definitions (id -> definition dictionary) the player can find.
var _catalog: Dictionary = {}
## Collected items in the order they were found.
var _items: Array[EvidenceItem] = []


func _init(catalog: Dictionary) -> void:
	_catalog = catalog


## Loads a catalog of evidence definitions from a JSON file ({"evidence": [{id, title, description}]}).
## Returns an empty catalog (and logs why) if the file is missing or invalid.
static func load_catalog(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("EvidenceInventory: file not found: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary) or not ((parsed as Dictionary).get("evidence") is Array):
		push_error("EvidenceInventory: %s needs an 'evidence' list" % path)
		return {}
	var catalog: Dictionary = {}
	for entry: Variant in (parsed as Dictionary)["evidence"]:
		if entry is Dictionary and EvidenceItem.from_dict(entry) != null:
			catalog[str(entry["id"])] = entry
	return catalog


## Collects the evidence with this id. Returns false if it is unknown or already collected.
func collect(evidence_id: String) -> bool:
	if has_item(evidence_id) or not _catalog.has(evidence_id):
		return false
	_items.append(EvidenceItem.from_dict(_catalog[evidence_id]))
	evidence_collected.emit(evidence_id)
	return true


## Marks a collected item verified. Returns false if it is not collected or already verified.
func verify(evidence_id: String) -> bool:
	var item := get_item(evidence_id)
	if item == null or item.verified:
		return false
	item.verified = true
	evidence_verified.emit(evidence_id)
	return true


func has_item(evidence_id: String) -> bool:
	return get_item(evidence_id) != null


## The collected item with this id, or null.
func get_item(evidence_id: String) -> EvidenceItem:
	for item in _items:
		if item.id == evidence_id:
			return item
	return null


## True only if the item is collected and verified.
func is_verified(evidence_id: String) -> bool:
	var item := get_item(evidence_id)
	return item != null and item.verified


## True if this id is a piece of evidence that exists in the game (collected or not).
func knows(evidence_id: String) -> bool:
	return _catalog.has(evidence_id)


## How many collected items are verified.
func verified_count() -> int:
	var count := 0
	for item in _items:
		if item.verified:
			count += 1
	return count


## How many pieces of evidence exist in the whole game.
func catalog_size() -> int:
	return _catalog.size()


## All collected items, in the order they were found.
func items() -> Array[EvidenceItem]:
	return _items
