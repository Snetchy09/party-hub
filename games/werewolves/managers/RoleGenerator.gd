class_name RoleGenerator
extends RefCounted


func generate_roles(
	player_count: int,
	role_manager: RoleManager
) -> Array[RoleData]:

	var roles: Array[RoleData] = []

	# -----------------------
	# Werewolves
	# -----------------------

	var wolf_count := get_werewolf_count(player_count)

	for i in range(wolf_count):
		roles.append(role_manager.get_role("werewolf"))

	# -----------------------
	# Required village roles
	# -----------------------

	if player_count >= 6:
		roles.append(role_manager.get_role("doctor"))

	if player_count >= 7:
		roles.append(role_manager.get_role("blue_seer"))

	# -----------------------
	# Fill remaining slots
	# -----------------------

	while roles.size() < player_count:
		roles.append(role_manager.get_role("villager"))

	return roles


func get_werewolf_count(player_count: int) -> int:

	if player_count <= 6:
		return 1

	if player_count <= 11:
		return 2

	if player_count <= 16:
		return 3

	return 4
