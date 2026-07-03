class_name RoleGenerator
extends RefCounted

func generate_roles(player_count: int, role_manager: RoleManager, settings: Dictionary = {}) -> Array[RoleData]:
	var roles: Array[RoleData] = []
	var used_unique: Array[String] = []

	var role_pack: String = settings.get("role_pack", "Advanced")

	var wolf_count := _get_werewolf_count(player_count)
	for i in range(wolf_count):
		roles.append(role_manager.get_role("werewolf"))

	if role_pack == "Basic":
		_try_add(roles, role_manager, "aura_seer", used_unique, player_count)
		_try_add(roles, role_manager, "witch", used_unique, player_count)
	else:
		var priority_order := [
			"aura_seer", "witch", "jailer", "investigator",
			"medium", "mirror", "judge", "streets_lady",
			"jester", "hunter", "bloody_seer", "hacker",
		]
		for role_id in priority_order:
			_try_add(roles, role_manager, role_id, used_unique, player_count)
			if roles.size() >= player_count:
				break

	while roles.size() < player_count:
		roles.append(role_manager.get_role("villager"))

	while roles.size() > player_count:
		roles.pop_back()

	roles.shuffle()
	return roles

func _try_add(roles: Array[RoleData], rm: RoleManager, id: String, used: Array[String], player_count: int) -> void:
	if id in used:
		return
	if roles.size() >= player_count:
		return
	var role := rm.get_role(id)
	if role == null:
		return
	if player_count < role.min_players:
		return
	roles.append(role)
	if role.unique:
		used.append(id)

func _get_werewolf_count(player_count: int) -> int:
	if player_count <= 5:  return 1
	if player_count <= 8:  return 2
	if player_count <= 12: return 3
	if player_count <= 16: return 4
	return 5
