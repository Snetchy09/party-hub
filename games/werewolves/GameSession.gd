class_name GameSession
extends Node

class WWPlayerState:
	var player_id: int
	var player: PlayerData
	var role: RoleData
	var alive: bool = true
	var statuses: Dictionary = {}  # "protected": true, "jailed": true, etc.
	var role_revealed: bool = false
	var voted_for: int = -1
	var action_submitted: bool = false

var players: Array[PlayerData] = []
var player_states: Dictionary = {}  # player_id -> WWPlayerState
var current_phase: String = "lobby"
var day: int = 1
var actions: Array[Action] = []
var votes: Dictionary = {}  # voter_id -> voted_for_id
var phase_timer: float = 0.0
var role_generator: RoleGenerator
var role_manager: RoleManager
var win_checker: WinChecker

func initialize_match(players_array: Array[PlayerData]) -> void:
	players = players_array
	role_generator = RoleGenerator.new()
	role_manager = RoleManager.new()
	win_checker = WinChecker.new()
	
	# Create player states
	for player in players:
		var state = WWPlayerState.new()
		state.player_id = player.id
		state.player = player
		player_states[player.id] = state
	
	print("Match initialized with %d players" % players.size())

func assign_roles() -> void:
	var roles = role_generator.generate_roles(players.size())
	var shuffled_roles = roles.duplicate()
	shuffled_roles.shuffle()
	
	var i = 0
	for player in players:
		player_states[player.id].role = shuffled_roles[i]
		i += 1
	
	print("Roles assigned:")
	for player in players:
		print("  %s -> %s" % [player.name, player_states[player.id].role.display_name])

func build_card_state() -> Dictionary:
	var cards = []
	for player in players:
		var state = player_states[player.id]
		var card_data = {
			"player_id": player.id,
			"name": player.name,
			"avatar": player.avatar_path,
			"alive": state.alive,
			"role": state.role.id,
			"role_revealed": state.role_revealed,
			"statuses": state.statuses.duplicate()
		}
		cards.append(card_data)
	
	return {
		"phase": current_phase,
		"day": day,
		"timer": phase_timer,
		"cards": cards
	}

func receive_action(player_id: int, action_type: String, target_id: int) -> void:
	var actor_state = player_states[player_id]
	var target_state = player_states[target_id]
	
	match action_type:
		"protect":
			var action = ProtectAction.new()
			action.actor = actor_state
			action.target = target_state
			actions.append(action)
			actor_state.action_submitted = true
		"kill":
			var action = KillAction.new()
			action.actor = actor_state
			action.target = target_state
			actions.append(action)
			actor_state.action_submitted = true
		"investigate":
			var action = InvestigateAction.new()
			action.actor = actor_state
			action.target = target_state
			actions.append(action)
			actor_state.action_submitted = true

func receive_vote(player_id: int, voted_for_id: int) -> void:
	votes[player_id] = voted_for_id
	player_states[player_id].voted_for = voted_for_id

func check_win() -> Dictionary:
	var village_alive = 0
	var werewolf_alive = 0
	
	for state in player_states.values():
		if not state.alive:
			continue
		if state.role.team == "village":
			village_alive += 1
		elif state.role.team == "werewolves":
			werewolf_alive += 1
	
	if werewolf_alive == 0:
		return {"winner": "village", "reason": "All werewolves eliminated"}
	
	if werewolf_alive >= village_alive:
		return {"winner": "werewolves", "reason": "Werewolves outnumber village"}
	
	return {"winner": null, "reason": "Game continues"}
