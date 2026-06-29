class_name WWPlayerState
extends RefCounted

var player: PlayerData
var role: RoleData
var alive: bool = true  # ← ADD THIS
var statuses: Dictionary = {}  # ← CHANGE FROM Array to Dictionary
var role_revealed: bool = false  # ← ADD THIS
var night_action: Dictionary = {}
var vote: int = -1
var lover: int = -1
var team_override: String = ""
var death_cause: String = ""
var action_submitted: bool = false  # ← ADD THIS

func _init(player_data: PlayerData) -> void:
	player = player_data
	role = null
	alive = true
	statuses = {}
