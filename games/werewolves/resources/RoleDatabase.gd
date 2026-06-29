class_name RoleDatabase
extends RefCounted

var _roles: Dictionary = {}

func register_role(role: RoleData) -> void:
	_roles[role.id] = role

func has_role(id: String) -> bool:
	return _roles.has(id)

func get_role(id: String) -> RoleData:
	if not _roles.has(id):
		push_error("Role '%s' does not exist." % id)
		return null
	return _roles[id]

func get_all_roles() -> Array:
	return _roles.values()

func clear() -> void:
	_roles.clear()
