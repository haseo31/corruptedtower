class_name Showdown
extends RefCounted
## Turn-based rules for a boss showdown: the player presents evidence against the
## boss's current lie. Countering it removes the lie; anything else raises the
## Cover-up meter. Pure rules with no scene or UI, so it can be unit tested headless.
## Evidence is owned by the inventory, never by this class, so a restart keeps it.

signal lie_removed(lie_id: String)
signal cover_up_filled(cover_up: int)
signal showdown_won
signal showdown_lost

enum State { ACTIVE, WON, LOST }
enum Result {
	COUNTERED, ## The evidence countered the current lie.
	WRONG_EVIDENCE, ## Wrong or unverified evidence; the Cover-up meter rose.
	IGNORED, ## The showdown is already over.
}

## The current state of the showdown.
var state: State = State.ACTIVE
## The Cover-up meter; the showdown is lost when it reaches the boss's maximum.
var cover_up: int = 0

var _boss: BossData
var _lie_index: int = 0


func _init(boss: BossData) -> void:
	_boss = boss


## The lie the player must counter next, or null once the showdown is over.
func current_lie() -> BossData.Lie:
	if state != State.ACTIVE:
		return null
	return _boss.lies[_lie_index]


## Plays one turn. Only verified evidence that counters the current lie succeeds.
func present_evidence(evidence_id: String, verified: bool) -> Result:
	if state != State.ACTIVE:
		return Result.IGNORED
	var lie := _boss.lies[_lie_index]
	if verified and evidence_id in lie.counter_evidence_ids:
		_lie_index += 1
		lie_removed.emit(lie.id)
		if _lie_index >= _boss.lies.size():
			state = State.WON
			showdown_won.emit()
		return Result.COUNTERED
	cover_up = mini(cover_up + _boss.wrong_evidence_penalty, _boss.cover_up_max)
	cover_up_filled.emit(cover_up)
	if cover_up >= _boss.cover_up_max:
		state = State.LOST
		showdown_lost.emit()
	return Result.WRONG_EVIDENCE


## Plays one turn using an item from the player's inventory. Evidence the player has
## not collected counts as wrong, and so does evidence that is not yet verified.
func present_from(inventory: EvidenceInventory, evidence_id: String) -> Result:
	return present_evidence(evidence_id, inventory.is_verified(evidence_id))


## Starts the showdown over: all lies return and the Cover-up meter empties.
func restart() -> void:
	state = State.ACTIVE
	cover_up = 0
	_lie_index = 0
