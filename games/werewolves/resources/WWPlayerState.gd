class_name WWPlayerState
extends RefCounted

var player: PlayerData
var role: RoleData          # assigned role
var statuses: Array = []    # e.g. ["used_ability", "cursed"]
var night_action: Dictionary = {}  # details of chosen action
var vote: int = -1          # voted player ID
var lover: int = -1         # ID of lover (if any)
var team_override: String = "" # if role is changed by effect
var death_cause: String = ""   # e.g. "night kill", "lynch"

func _init(player_data: PlayerData) -> void:
	player = player_data
	role = null
	statuses.clear()
