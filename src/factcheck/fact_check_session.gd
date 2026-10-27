class_name FactCheckSession
extends RefCounted
## Runs one fact-check challenge against the player's inventory. A correct answer
## marks the evidence verified; a wrong answer leaves it unverified and allows a retry.

signal answered(correct: bool)

enum Result { CORRECT, WRONG, NOT_ACTIVE }

var challenge: FactCheckChallenge

var _inventory: EvidenceInventory
var _active: bool = false


func _init(inventory: EvidenceInventory) -> void:
	_inventory = inventory


## Starts a challenge for a collected, still-unverified item. Returns false if the
## item is not collected, is already verified, or no challenge exists for it.
func start(evidence_id: String, challenges: Dictionary) -> bool:
	if not _inventory.has_item(evidence_id) or _inventory.is_verified(evidence_id):
		return false
	if not challenges.has(evidence_id):
		return false
	challenge = challenges[evidence_id]
	_active = true
	return true


## Answers the active challenge with the chosen option.
func submit(option_index: int) -> Result:
	if not _active:
		return Result.NOT_ACTIVE
	if challenge.is_correct(option_index):
		_active = false
		_inventory.verify(challenge.evidence_id)
		answered.emit(true)
		return Result.CORRECT
	answered.emit(false)
	return Result.WRONG
