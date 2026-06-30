class_name WWPlayerState
extends RefCounted

var player: PlayerData
var role: RoleData
var role_revealed: bool = false
var alive: bool = true
var death_cause: String = ""  # "night_kill" | "voted_out" | "jailer" | "sacrifice" | "hacker" | "reflected"

## Status effects, all in one dictionary for easy serialization.
## Keys used: "protected", "cursed" (int days left), "blessed", "jailed",
## "hacked", "visited" (int player_id who visited)
var statuses: Dictionary = {}

## Role-specific runtime data
var witch_type: String = ""              # "white" | "black"
var night_uses_remaining: int = -1       # -1 = unlimited
var investigator_group: Array[int] = []
var hunter_target_id: int = -1
var hacked_target_id: int = -1
var hacked_target_start_day: int = 0
var medium_revived: bool = false
var judge_skip_used: bool = false
var judge_free_used: bool = false
var mirror_uses: int = 2
var vote: int = -1
var action_submitted: bool = false
var private_messages: Array[Dictionary] = []

func _init(p_player: PlayerData = null) -> void:
	player = p_player
	statuses = {}

func can_use_ability() -> bool:
	if statuses.get("cursed", 0) > 0:
		return false
	if night_uses_remaining == 0:
		return false
	return true

func consume_use() -> void:
	if night_uses_remaining > 0:
		night_uses_remaining -= 1

func tick_statuses() -> void:
	# Call once per morning
	if statuses.has("cursed"):
		statuses["cursed"] -= 1
		if statuses["cursed"] <= 0:
			statuses.erase("cursed")
	statuses.erase("protected")
	statuses.erase("blessed")
	statuses.erase("visited")
	statuses.erase("hacked")
