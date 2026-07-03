class_name RoleAssignmentSystem
extends RefCounted

func assign_roles(player_states: Array[WWPlayerState], roles: Array[RoleData]) -> void:
	assert(player_states.size() == roles.size(), "Player/role count mismatch")
	var shuffled_roles := roles.duplicate()
	shuffled_roles.shuffle()
	for i in range(player_states.size()):
		player_states[i].role = shuffled_roles[i]
