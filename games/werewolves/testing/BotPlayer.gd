class_name BotPlayer
extends Node

var game_session: GameSession
var player_id: int
var network_manager: NetworkManager

func submit_night_action() -> void:
	var player_state = game_session.player_states[player_id]
	
	# Get list of valid targets
	var targets = []
	for other_id in game_session.player_states:
		if other_id == player_id:
			continue
		if not game_session.player_states[other_id].alive:
			continue
		targets.append(other_id)
	
	if targets.size() == 0:
		return
	
	var target_id = targets[randi() % targets.size()]
	var action_type = ""
	
	match player_state.role.id:
		"doctor":
			action_type = "protect"
		"werewolf":
			action_type = "kill"
		"blue_seer":
			action_type = "investigate"
	
	if action_type:
		print("Bot %s (%s) doing: %s on %s" % [player_state.player.name, player_state.role.id, action_type, game_session.player_states[target_id].player.name])
		game_session.receive_action(player_id, action_type, target_id)

func submit_vote() -> void:
	var living_players = []
	for other_id in game_session.player_states:
		if other_id == player_id:
			continue
		if game_session.player_states[other_id].alive:
			living_players.append(other_id)
	
	if living_players.size() == 0:
		return
	
	var target_id = living_players[randi() % living_players.size()]
	print("Bot %s voting for %s" % [player_id, target_id])
	game_session.receive_vote(player_id, target_id)
