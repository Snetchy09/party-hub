class_name PhaseController
extends Node

var game_session: GameSession
var network_manager: NetworkManager
var phase_timers: Dictionary = {
	"night": 30.0,
	"discussion": 60.0,
	"voting": 45.0
}
var current_timer: float = 0.0

func start_game() -> void:
	game_session.assign_roles()
	game_session.current_phase = "role_reveal"
	
	# Broadcast to all clients: role reveal screen
	network_manager.broadcast_to_all({
		"type": "phase_change",
		"phase": "role_reveal",
		"state": game_session.build_card_state()
	})
	
	# After animation (5 seconds), start night
	await get_tree().create_timer(5.0).timeout
	start_night()

func start_night() -> void:
	game_session.current_phase = "night"
	game_session.actions.clear()
	game_session.votes.clear()
	current_timer = phase_timers["night"]
	
	print("Night %d started" % game_session.day)
	
	# Broadcast to all clients
	network_manager.broadcast_to_all({
		"type": "phase_change",
		"phase": "night",
		"day": game_session.day,
		"state": game_session.build_card_state()
	})

func start_morning() -> void:
	game_session.current_phase = "morning"
	
	# Resolve all actions
	resolve_night_actions()
	
	# Broadcast morning state with results
	network_manager.broadcast_to_all({
		"type": "phase_change",
		"phase": "morning",
		"day": game_session.day,
		"state": game_session.build_card_state()
	})
	
	await get_tree().create_timer(3.0).timeout
	start_discussion()

func start_discussion() -> void:
	game_session.current_phase = "discussion"
	current_timer = phase_timers["discussion"]
	
	network_manager.broadcast_to_all({
		"type": "phase_change",
		"phase": "discussion",
		"state": game_session.build_card_state()
	})

func start_voting() -> void:
	game_session.current_phase = "voting"
	current_timer = phase_timers["voting"]
	
	network_manager.broadcast_to_all({
		"type": "phase_change",
		"phase": "voting",
		"state": game_session.build_card_state()
	})

func start_execution() -> void:
	game_session.current_phase = "execution"
	
	# Count votes
	var vote_counts: Dictionary = {}
	for voter_id in game_session.votes:
		var voted_for = game_session.votes[voter_id]
		vote_counts[voted_for] = vote_counts.get(voted_for, 0) + 1
	
	# Find who got the most votes
	var executed_player_id = vote_counts.keys()[0]
	var max_votes = vote_counts[executed_player_id]
	
	for player_id in vote_counts:
		if vote_counts[player_id] > max_votes:
			executed_player_id = player_id
			max_votes = vote_counts[player_id]
	
	# Execute player (reveal role, mark dead)
	var executed_state = game_session.player_states[executed_player_id]
	executed_state.alive = false
	executed_state.role_revealed = true
	
	print("%s was executed! They were a %s." % [executed_state.player.name, executed_state.role.display_name])
	
	network_manager.broadcast_to_all({
		"type": "phase_change",
		"phase": "execution",
		"executed_player_id": executed_player_id,
		"state": game_session.build_card_state()
	})
	
	await get_tree().create_timer(3.0).timeout
	check_win()

func check_win() -> void:
	var result = game_session.check_win()
	
	if result["winner"]:
		end_game(result["winner"], result["reason"])
	else:
		game_session.day += 1
		start_night()

func end_game(winner: String, reason: String) -> void:
	network_manager.broadcast_to_all({
		"type": "game_end",
		"winner": winner,
		"reason": reason,
		"state": game_session.build_card_state()
	})
	
	print("Game Over! %s wins: %s" % [winner.to_upper(), reason])

func resolve_night_actions() -> void:
	# Resolve all actions in order
	for action in game_session.actions:
		action.resolve()
	
	game_session.actions.clear()

func _process(delta: float) -> void:
	if game_session.current_phase in ["night", "discussion", "voting"]:
		current_timer -= delta
		
		# Broadcast timer update
		network_manager.broadcast_to_all({
			"type": "timer_update",
			"timer": current_timer
		})
		
		if current_timer <= 0:
			match game_session.current_phase:
				"night":
					start_morning()
				"discussion":
					start_voting()
				"voting":
					start_execution()
