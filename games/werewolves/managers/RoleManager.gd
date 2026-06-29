class_name RoleManager
extends Node

const ROLES_PATH := "res://games/werewolves/data/roles.json"

var database := RoleDatabase.new()

func _ready() -> void:
	load_roles()

func load_roles() -> void:
	database = RoleDatabase.new()
	var file := FileAccess.open(ROLES_PATH, FileAccess.READ)
	if file == null:
		push_error("Unable to open roles.json")
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_error("Invalid roles.json")
		return
	for data in json.data:
		var role := RoleData.new()
		role.id = data["id"]
		role.display_name = data["display_name"]
		role.description = data.get("description", "")
		# Rename 'alignment' -> 'team'
		role.team = data.get("team", data.get("alignment", ""))
		role.power = data.get("power", 0)
		# New fields:
		role.rarity = data.get("rarity", 1)
		role.unique = data.get("unique", false)
		role.min_players = data.get("min_players", 1)
		role.tags = []
		for tag in data["tags"]:
			role.tags.append(tag)
		role.appears_good = data.get("appears_good", false)
		role.appears_bad = data.get("appears_bad", false)
		role.can_act_at_night = data.get("can_act_at_night", false)
		database.register_role(role)

func get_role(id: String) -> RoleData:
	return database.get_role(id)

func get_all_roles() -> Array[RoleData]:
	return database.get_all_roles()
