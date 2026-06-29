class_name PhaseManager
extends RefCounted

var match_manager: MatchManager
var action_queue: Array[Action] = []
var votes: Dictionary = {}  # player_id -> voted_for_id

signal phase_started(phase: String)
signal phase_ended(phase: String)

func start_night() -> void:
	match_manager.current_phase = "night"
	match_manager.phase_timer = 30.0
	action_queue.clear()
	phase_started.emit("night")
	print("Night %d started" % match_manager.day)

func submit_night_action(actor_id: int, action_type: String, target_id: int) -> void:
	match_manager.submit_action(actor_id, action_type, target_id)

func end_night() -> void:
	# All actions already resolved, move to morning
	match_manager.current_phase = "morning"
	phase_ended.emit("night")
	print("Night %d ended" % match_manager.day)

func start_voting() -> void:
	match_manager.current_phase = "voting"
	match_manager.phase_timer = 45.0
	votes.clear()
	phase_started.emit("voting")
	print("Voting started")

func submit_vote(voter_id: int, voted_for_id: int) -> void:
	votes[voter_id] = voted_for_id

func end_voting() -> void:
	# Count votes
	var vote_counts: Dictionary = {}
	for voter_id in votes:
		var voted_for = votes[voter_id]
		vote_counts[voted_for] = vote_counts.get(voted_for, 0) + 1
	
	if vote_counts.is_empty():
		print("No votes cast")
		return
	
	# Find player with most votes
	var executed_id = vote_counts.keys()[0]
	var max_votes = vote_counts[executed_id]
	
	for player_id in vote_counts:
		if vote_counts[player_id] > max_votes:
			executed_id = player_id
			max_votes = vote_counts[player_id]
	
	# Execute player
	var executed = match_manager.get_player_state(executed_id)
	executed.alive = false
	executed.role_revealed = true
	
	print("%s was voted out! They were a %s." % [executed.player.name, executed.role.display_name])
	
	match_manager.current_phase = "execution"
	phase_ended.emit("voting")

func check_and_advance() -> void:
	var result = match_manager.check_win()
	
	if result["winner"]:
		match_manager.current_phase = "game_end"
		print("Game Over! %s wins: %s" % [result["winner"], result["reason"]])
	else:
		match_manager.day += 1
		start_night()

func _process(delta: float) -> void:
	if match_manager.current_phase in ["night", "voting"]:
		match_manager.phase_timer -= delta
		
		if match_manager.phase_timer <= 0:
			match match_manager.current_phase:
				"night":
					end_night()
				"voting":
					end_voting()
					check_and_advance()
