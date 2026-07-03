class_name RoleManager
extends RefCounted

var database: RoleDatabase

func _init() -> void:
	load_roles()

func load_roles() -> void:
	database = RoleDatabase.new()
	database.load_from_json("res://games/werewolves/data/roles.json")

func get_role(id: String) -> RoleData:
	return database.get_role(id)

func get_all_roles() -> Array:
	return database.get_all_roles()
