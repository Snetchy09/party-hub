class_name RoleAssignmentSystem
extends RefCounted


func assign_roles(players: Array[WWPlayerState], roles: Array[RoleData]) -> void:
	assert(players.size() == roles.size())

	roles.shuffle()

	for i in players.size():
		players[i].role = roles[i]
