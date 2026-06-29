class_name TestMatchBuilder
extends RefCounted
func build(player_count: int, role_manager: RoleManager) -> WerewolvesMatch:
	var current_match := WerewolvesMatch.new()
	var generator := RoleGenerator.new()
	var assigner := RoleAssignmentSystem.new()
	# Create fake players
	for i in range(player_count):
		var player := PlayerData.new()
		player.id = i
		player.username = "Player %d" % (i + 1)
		var state := WWPlayerState.new(player)
		current_match.players.append(state)
	# Generate and assign roles
	var roles := generator.generate_roles(player_count, role_manager)
	assigner.assign_roles(current_match.players, roles)
	return current_match
