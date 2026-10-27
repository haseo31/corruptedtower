class_name EvidenceItem
extends RefCounted
## One piece of evidence the player can collect. New items start unverified;
## the fact-check mini-game marks them verified.

var id: String = ""
var title: String = ""
var description: String = ""
var verified: bool = false


## Builds an item from a data entry. Returns null (and logs why) if the entry is invalid.
static func from_dict(data: Dictionary) -> EvidenceItem:
	var item := EvidenceItem.new()
	item.id = str(data.get("id", ""))
	item.title = str(data.get("title", ""))
	item.description = str(data.get("description", ""))
	if item.id.is_empty() or item.title.is_empty():
		push_error("EvidenceItem: each entry needs an id and a title")
		return null
	return item
