class_name MatchManager
extends RefCounted

var match_state: WerewolvesMatch
var role_manager: RoleManager
var phase_timer: float = 0.0
var current_phase: String = "lobby"  # "lobby", "role_reveal", "night", "morning", "voting", "execution", "win_check"
var day: int = 1

signal phase_changed(phase: String)
signal match_ended(winner: String, reason: String)

func initialize_match(players: Array[WWPlayerState]) -> void:
	match_state = WerewolvesMatch.new()
	match_state.players = players
	role_manager = RoleManager.new()
	role_manager.load_roles()
	
	# Generate and assign roles
	var generator = RoleGenerator.new()
	var roles = generator.generate_roles(players.size(), role_manager)
	
	var assigner = RoleAssignmentSystem.new()
	assigner.assign_roles(players, roles)
	
	print("Match initialized: %d players" % players.size())

func get_card_state() -> Dictionary:
	var cards = []
	for player_state in match_state.players:
		cards.append({
			"player_id": player_state.player.id,
			"name": player_state.player.name,
			"alive": player_state.alive,
			"role": player_state.role.id if player_state.role else "unknown",
			"role_revealed": player_state.role_revealed,
			"statuses": player_state.statuses.duplicate()
		})
	
	return {
		"phase": current_phase,
		"day": day,
		"timer": phase_timer,
		"cards": cards
	}

func submit_action(actor_id: int, action_type: String, target_id: int) -> void:
	var actor = get_player_state(actor_id)
	var target = get_player_state(target_id)
	
	if actor == null or target == null:
		push_error("Invalid action submission")
		return
	
	# Create and resolve action
	var action: Action
	match action_type:
		"protect":
			action = ProtectAction.new()
		"kill":
			action = KillAction.new()
		"investigate":
			action = InvestigateAction.new()
		_:
			return
	
	action.actor = actor
	action.target = target
	action.resolve()

func check_win() -> Dictionary:
	var village_alive = 0
	var werewolf_alive = 0
	
	for player_state in match_state.players:
		if not player_state.alive:
			continue
		if player_state.role.team == "village":
			village_alive += 1
		elif player_state.role.team == "werewolves":
			werewolf_alive += 1
	
	if werewolf_alive == 0:
		return {"winner": "village", "reason": "All werewolves eliminated"}
	
	if werewolf_alive >= village_alive:
		return {"winner": "werewolves", "reason": "Werewolves outnumber village"}
	
	return {"winner": null, "reason": "Game continues"}

func get_player_state(player_id: int) -> WWPlayerState:
	for player_state in match_state.players:
		if player_state.player.id == player_id:
			return player_state
	return null
