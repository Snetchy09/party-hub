class_name RoleAssignmentSystem
extends RefCounted

func assign_roles(players: Array[WWPlayerState], roles: Array[RoleData]) -> void:
	assert(players.size() == roles.size(), "Player and role count must match")
	roles.shuffle()
	for i in range(players.size()):
		players[i].role = roles[i]
