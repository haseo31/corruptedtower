class_name DialogueRunner
extends RefCounted
## Runs one conversation from data. A conversation is a set of nodes; each node shows
## its lines one at a time, then either offers choices, moves to the next node, or ends.
## A node can hand the player evidence (straight into the inventory, unverified) and can
## redirect to a different node when the player already has some evidence, so an NPC
## never hands over the same item twice. Choices can set flags the story remembers
## ("set_flags"), show only when a flag is set or not set ("requires_flag", "hide_if_flag"),
## and a node can redirect on a flag ("redirect_if_flag") or score a right or wrong decision
## ("record_choice"). Pure rules with no UI.

signal line_changed(speaker: String, text: String)
signal choices_shown(choices: Array)
signal evidence_granted(evidence_id: String)
signal finished

var _inventory: EvidenceInventory
var _nodes: Dictionary = {}
var _node: Dictionary = {}
var _line_index: int = 0
var _active: bool = false
var _choosing: bool = false
## The choices actually shown for the current node (some may be hidden by flags).
var _shown_choices: Array = []


func _init(inventory: EvidenceInventory) -> void:
	_inventory = inventory


## Loads every dialogue from a JSON file ({"dialogues": [...]}), keyed by id. A dialogue
## whose nodes point at nodes that do not exist is skipped and logged.
static func load_all(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("DialogueRunner: file not found: %s" % path)
		return {}
	var parsed: Variant = Tr.tree(JSON.parse_string(FileAccess.get_file_as_string(path)))
	if not (parsed is Dictionary) or not ((parsed as Dictionary).get("dialogues") is Array):
		push_error("DialogueRunner: %s needs a 'dialogues' list" % path)
		return {}
	var dialogues: Dictionary = {}
	for entry: Variant in (parsed as Dictionary)["dialogues"]:
		if entry is Dictionary and _is_valid(entry):
			dialogues[str(entry["id"])] = entry
	return dialogues


## Builds a one-node dialogue that shows a line and hands over evidence (for picking up a clue).
static func pickup_dialogue(line: String, evidence_id: String) -> Dictionary:
	return {
		"id": "pickup_" + evidence_id,
		"start": "pickup",
		"nodes": {"pickup": {"speaker": "", "lines": [line], "give_evidence": evidence_id}},
	}


## Builds a one-node dialogue that just shows a line (a notice, or a boss's parting words).
static func message_dialogue(speaker: String, line: String) -> Dictionary:
	return {
		"id": "message",
		"start": "message",
		"nodes": {"message": {"speaker": speaker, "lines": [line]}},
	}


## Starts a conversation. Returns false if one is already running or the data is unusable.
func start(dialogue: Dictionary) -> bool:
	if _active or not _is_valid(dialogue):
		return false
	_nodes = dialogue["nodes"]
	_enter(str(dialogue["start"]))
	return true


func is_active() -> bool:
	return _active


## True while the player must pick one of the shown choices.
func is_choosing() -> bool:
	return _choosing


## Moves on from the current line: to the next line, then to choices, the next node, or the end.
func advance() -> void:
	if not _active or _choosing:
		return
	_line_index += 1
	if _line_index < (_node["lines"] as Array).size():
		_show_line()
		return
	_shown_choices = _visible_choices(_node.get("choices", []))
	if not _shown_choices.is_empty():
		_choosing = true
		var texts: Array[String] = []
		for choice: Dictionary in _shown_choices:
			texts.append(str(choice["text"]))
		choices_shown.emit(texts)
	elif _node.has("next"):
		_enter(str(_node["next"]))
	else:
		_finish()


## Picks one of the shown choices.
func choose(index: int) -> void:
	if not _choosing or index < 0 or index >= _shown_choices.size():
		return
	_choosing = false
	var choice: Dictionary = _shown_choices[index]
	if choice.has("next"):
		_enter(str(choice["next"]))
	else:
		_finish()


func _enter(node_id: String) -> void:
	_node = _nodes[node_id]
	var redirect: Variant = _node.get("redirect_if_has")
	if redirect is Dictionary and _inventory.has_item(str(redirect["evidence"])):
		_node = _nodes[str(redirect["node"])]
	for flag_redirect: Dictionary in _redirects(_node.get("redirect_if_flag")):
		if GameSession.has_flag(str(flag_redirect["flag"])):
			_node = _nodes[str(flag_redirect["node"])]
			break
	for flag: Variant in _node.get("set_flags", []):
		GameSession.set_flag(str(flag))
	if _node.has("record_choice"):
		GameSession.record_choice(bool(_node["record_choice"]))
	var evidence_id := str(_node.get("give_evidence", ""))
	if not evidence_id.is_empty() and _inventory.collect(evidence_id):
		evidence_granted.emit(evidence_id)
	_active = true
	_choosing = false
	_line_index = 0
	_show_line()


## The node's choices that the flags allow: "requires_flag" needs that flag set, "hide_if_flag" hides when it is.
func _visible_choices(choices: Array) -> Array:
	var shown: Array = []
	for choice: Dictionary in choices:
		if choice.has("requires_flag") and not GameSession.has_flag(str(choice["requires_flag"])):
			continue
		if choice.has("hide_if_flag") and GameSession.has_flag(str(choice["hide_if_flag"])):
			continue
		shown.append(choice)
	return shown


## "redirect_if_flag" is one {"flag", "node"} or a list of them; always returns a list.
static func _redirects(raw: Variant) -> Array:
	if raw is Dictionary:
		return [raw]
	return raw if raw is Array else []


func _show_line() -> void:
	line_changed.emit(str(_node.get("speaker", "")), str((_node["lines"] as Array)[_line_index]))


func _finish() -> void:
	_active = false
	_choosing = false
	finished.emit()


static func _is_valid(dialogue: Dictionary) -> bool:
	var nodes: Variant = dialogue.get("nodes")
	if str(dialogue.get("id", "")).is_empty() or not (nodes is Dictionary) \
			or not (nodes as Dictionary).has(str(dialogue.get("start", ""))):
		push_error("DialogueRunner: a dialogue needs an id, nodes, and a start node that exists")
		return false
	var node_table: Dictionary = nodes
	for node_id: String in node_table:
		var node: Variant = node_table[node_id]
		if not (node is Dictionary) or not ((node as Dictionary).get("lines") is Array) \
				or ((node as Dictionary)["lines"] as Array).is_empty():
			push_error("DialogueRunner: node '%s' needs at least one line" % node_id)
			return false
		var targets: Array = []
		if (node as Dictionary).has("next"):
			targets.append(node["next"])
		var redirect: Variant = (node as Dictionary).get("redirect_if_has")
		if redirect is Dictionary:
			targets.append(redirect.get("node", ""))
		for flag_redirect: Dictionary in _redirects((node as Dictionary).get("redirect_if_flag")):
			targets.append(flag_redirect.get("node", ""))
		var choices: Variant = (node as Dictionary).get("choices", [])
		if choices is Array:
			for choice: Variant in choices:
				if not (choice is Dictionary) or str(choice.get("text", "")).is_empty():
					push_error("DialogueRunner: node '%s' has a choice with no text" % node_id)
					return false
				if choice.has("next"):
					targets.append(choice["next"])
		for target: Variant in targets:
			if not node_table.has(str(target)):
				push_error("DialogueRunner: node '%s' points at missing node '%s'" % [node_id, target])
				return false
	return true
