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
		role.description = data["description"]

		# We'll rename this to 'team' later
		role.alignment = data["alignment"]

		role.power = data["power"]
		role.appears_good = data["appears_good"]
		role.appears_bad = data["appears_bad"]
		role.can_act_at_night = data["can_act_at_night"]

		database.register_role(role)


func get_role(id: String) -> RoleData:
	return database.get_role(id)


func get_all_roles() -> Array[RoleData]:
	return database.get_all_roles()
