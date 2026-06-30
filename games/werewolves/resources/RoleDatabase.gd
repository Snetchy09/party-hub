class_name RoleDatabase
extends RefCounted

var roles: Dictionary = {}  # id -> RoleData

func load_from_json(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("RoleDatabase: could not open %s" % path)
		return
	var text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		push_error("RoleDatabase: JSON parse error in %s: %s" % [path, json.get_error_message()])
		return

	var data: Array = json.data
	roles.clear()
	for entry in data:
		var role := RoleData.new()
		role.from_dict(entry)
		roles[role.id] = role

func get_role(id: String) -> RoleData:
	return roles.get(id, null)

func get_all_roles() -> Array:
	return roles.values()
