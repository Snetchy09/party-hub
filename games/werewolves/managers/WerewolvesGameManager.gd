class_name WerewolvesGameManager
extends Node

var match_state: WerewolvesMatch
var role_manager: RoleManager
var vote_manager: VoteManager
var chat_manager: ChatManager
var resolver: NightActionResolver
var win_checker: WinConditionChecker

var pending_night_actions: Array[Dictionary] = []
var phase_timer: float = 0.0
var is_running: bool = false
var last_night_events: Array[Dictionary] = []
var players_ready_for_night: Array[int] = []

const PHASE_TIMES := {
	"night": 30.0,
	"discussion": 60.0,
	"voting": 45.0,
}

func start_game(players: Array[PlayerData], settings: Dictionary) -> void:
	role_manager = RoleManager.new()
	vote_manager = VoteManager.new()
	chat_manager = ChatManager.new()
	resolver = NightActionResolver.new()
	win_checker = WinConditionChecker.new()

	vote_manager.jester_won.connect(_on_jester_won)
	vote_manager.hunter_won.connect(_on_hunter_won)

	var player_states: Array[WWPlayerState] = []
	for p in players:
		player_states.append(WWPlayerState.new(p))

	match_state = WerewolvesMatch.new()
	match_state.players = player_states
	match_state.day_count = 0

	var generator := RoleGenerator.new()
	var roles := generator.generate_roles(players.size(), role_manager, settings)
	var assigner := RoleAssignmentSystem.new()
	assigner.assign_roles(player_states, roles)

	for state in player_states:
		_setup_special_role(state)

	is_running = true
	_start_role_reveal()

func _setup_special_role(state: WWPlayerState) -> void:
	if state.role == null:
		return
	match state.role.id:
		"witch":
			state.night_uses_remaining = 0
		"mirror":
			state.mirror_uses = 2
		"judge":
			state.judge_skip_used = false
			state.judge_free_used = false
		"jailer":
			state.night_uses_remaining = 1
		"medium":
			state.night_uses_remaining = 1
		"bloody_seer":
			state.night_uses_remaining = 1
		"hunter":
			var good_players := match_state.players.filter(func(s):
				return s.role and s.role.team == "village" and s.player.id != state.player.id
			)
			if good_players.size() > 0:
				good_players.shuffle()
				state.hunter_target_id = good_players[0].player.id
		"hacker":
			state.night_uses_remaining = -1

func _start_role_reveal() -> void:
	match_state.phase = "role_reveal"
	_broadcast_state_to_all()

func begin_night_loop() -> void:
	_start_night()

func _start_night() -> void:
	match_state.day_count += 1
	match_state.phase = "night"
	phase_timer = PHASE_TIMES["night"]
	pending_night_actions.clear()
	chat_manager.clear_night_chats()

	for state in match_state.players:
		if state.statuses.get("jailed", false):
			for jstate in match_state.players:
				if jstate.role and jstate.role.id == "jailer" and jstate.alive:
					chat_manager.open_jailer_chat(jstate.player.id, state.player.id)
			break

	_broadcast_phase_change("night")

func receive_action(sender_id: int, message: Dictionary) -> void:
	if not is_running:
		return
	match message.get("type", ""):
		"night_action":
			_handle_night_action(sender_id, message)
		"vote":
			vote_manager.submit_vote(sender_id, message.get("target_id", -1), match_state)
			_broadcast_vote_counts()
		"witch_choice":
			_handle_witch_choice(sender_id, message.get("choice", "white"))
		"investigator_group":
			_handle_investigator_group(sender_id, message.get("group", []))
		"chat_message":
			_handle_chat_message(sender_id, message.get("text", ""))
		"judge_skip":
			_handle_judge_skip(sender_id)
		"judge_free":
			_handle_judge_free(sender_id)
		"jailer_target":
			_handle_jailer_target(sender_id, message.get("target_id", -1))
		"hacker_target":
			_handle_hacker_target(sender_id, message.get("target_id", -1))
		"reveal_done":
			_handle_reveal_done(sender_id)

func _handle_reveal_done(sender_id: int) -> void:
	if sender_id in players_ready_for_night:
		return
	players_ready_for_night.append(sender_id)
	if players_ready_for_night.size() >= match_state.players.size():
		begin_night_loop()

func _handle_night_action(sender_id: int, message: Dictionary) -> void:
	var state := match_state.get_player_state(sender_id)
	if state == null or not state.alive:
		return
	pending_night_actions.append({
		"actor_id": sender_id,
		"action_type": message.get("action_type", ""),
		"target_id": message.get("target_id", -1),
	})
	state.action_submitted = true

func _handle_witch_choice(sender_id: int, choice: String) -> void:
	var state := match_state.get_player_state(sender_id)
	if state == null or state.role == null or state.role.id != "witch":
		return
	state.witch_type = choice
	state.night_uses_remaining = 2 if choice == "white" else 1

func _handle_investigator_group(sender_id: int, group: Array) -> void:
	var state := match_state.get_player_state(sender_id)
	if state == null or state.role == null or state.role.id != "investigator":
		return
	state.investigator_group.clear()
	for pid in group:
		state.investigator_group.append(int(pid))

func _handle_chat_message(sender_id: int, text: String) -> void:
	if text.strip_edges().is_empty():
		return
	var sender_state := match_state.get_player_state(sender_id)
	if sender_state == null:
		return

	if sender_state.role and sender_state.role.id == "medium":
		var msg := chat_manager.send_medium_message(sender_id, text)
		_relay_medium_chat(msg)
	elif sender_id == chat_manager.jailer_id or sender_id == chat_manager.jailed_id:
		var msg := chat_manager.send_jailer_message(sender_id, text)
		_relay_jailer_chat(msg)
	elif not sender_state.alive:
		var msg := chat_manager.send_medium_message(sender_id, text)
		_relay_medium_chat(msg)

func _handle_judge_skip(sender_id: int) -> void:
	var state := match_state.get_player_state(sender_id)
	if state == null or state.role == null or state.role.id != "judge" or state.judge_skip_used:
		return
	state.judge_skip_used = true
	if match_state.phase == "discussion":
		_start_night()

func _handle_judge_free(sender_id: int) -> void:
	var state := match_state.get_player_state(sender_id)
	if state == null or state.role == null or state.role.id != "judge" or state.judge_free_used:
		return
	state.judge_free_used = true
	for s in match_state.players:
		if s.statuses.get("jailed", false):
			s.statuses.erase("jailed")
			break

func _handle_jailer_target(sender_id: int, target_id: int) -> void:
	var state := match_state.get_player_state(sender_id)
	if state == null or state.role == null or state.role.id != "jailer":
		return
	var target_state := match_state.get_player_state(target_id)
	if target_state and target_state.alive:
		target_state.statuses["jailed"] = true

func _handle_hacker_target(sender_id: int, target_id: int) -> void:
	var state := match_state.get_player_state(sender_id)
	if state == null or state.role == null or state.role.id != "hacker":
		return
	var target_state := match_state.get_player_state(target_id)
	if target_state and target_state.alive and target_id != sender_id:
		state.hacked_target_id = target_id
		state.hacked_target_start_day = match_state.day_count

func _process(delta: float) -> void:
	if not is_running:
		return
	if match_state.phase in ["night", "discussion", "voting"]:
		phase_timer -= delta
		if phase_timer <= 0:
			_end_current_phase()
		else:
			if int(phase_timer * 10) % 10 == 0:
				_broadcast_state_to_all()

func _end_current_phase() -> void:
	match match_state.phase:
		"night":
			_end_night()
		"discussion":
			_start_voting()
		"voting":
			_end_voting()

func _end_night() -> void:
	last_night_events = resolver.resolve(match_state, pending_night_actions)
	match_state.phase = "morning"
	_broadcast_morning_results()

	var win_result := win_checker.check(match_state)
	if win_result["winner"] != "":
		_end_game(win_result)
		return

	await get_tree().create_timer(5.0).timeout
	_start_discussion()

func _start_discussion() -> void:
	match_state.phase = "discussion"
	phase_timer = PHASE_TIMES["discussion"]
	_broadcast_phase_change("discussion")

func _start_voting() -> void:
	match_state.phase = "voting"
	phase_timer = PHASE_TIMES["voting"]
	vote_manager.reset()
	_broadcast_phase_change("voting")

func _end_voting() -> void:
	var result := vote_manager.resolve_execution(match_state)
	match_state.phase = "execution"
	_broadcast_execution_result(result)

	if result.get("jester_win", false):
		_end_game({"winner": "jester", "reason": "The Jester tricked the village!", "winners": [result["executed_id"]]})
		return

	var win_result := win_checker.check(match_state)
	if win_result["winner"] != "":
		_end_game(win_result)
		return

	await get_tree().create_timer(5.0).timeout
	_start_night()

func _on_jester_won(_player_id: int) -> void:
	pass

func _on_hunter_won(hunter_id: int, _target_id: int) -> void:
	call_deferred("_end_game", {"winner": "hunter", "reason": "The Hunter's target was eliminated!", "winners": [hunter_id]})

func _end_game(result: Dictionary) -> void:
	is_running = false
	match_state.phase = "ended"
	match_state.winner = result["winner"]
	match_state.win_reason = result["reason"]
	match_state.winners = result.get("winners", [])
	_broadcast_game_end()

func _broadcast_state_to_all() -> void:
	for state in match_state.players:
		var pid: int = state.player.id
		var player_view := WWStateSerializer.build_for_player(match_state, pid)
		NetworkManager.send_to_peer(pid, {"type": "state_update", "state": player_view})

func _broadcast_phase_change(phase: String) -> void:
	_broadcast_state_to_all()
	NetworkManager.broadcast_to_all({"type": "phase_change", "phase": phase})

func _broadcast_vote_counts() -> void:
	var counts := vote_manager.get_public_vote_counts(match_state)
	NetworkManager.broadcast_to_all({"type": "vote_counts", "counts": counts})

func _broadcast_morning_results() -> void:
	_broadcast_state_to_all()
	NetworkManager.broadcast_to_all({"type": "phase_change", "phase": "morning", "events": last_night_events})

func _broadcast_execution_result(result: Dictionary) -> void:
	_broadcast_state_to_all()
	NetworkManager.broadcast_to_all({"type": "execution_result", "result": result})

func _broadcast_game_end() -> void:
	NetworkManager.broadcast_to_all({
		"type": "game_end",
		"winner": match_state.winner,
		"reason": match_state.win_reason,
		"winners": match_state.winners,
		"all_cards": WWStateSerializer.build_reveal_all(match_state),
	})

func _relay_jailer_chat(msg: Dictionary) -> void:
	NetworkManager.send_to_peer(chat_manager.jailer_id, {"type": "secret_chat_message", "chat": "jailer", "message": msg})
	NetworkManager.send_to_peer(chat_manager.jailed_id, {"type": "secret_chat_message", "chat": "jailer", "message": msg})

func _relay_medium_chat(msg: Dictionary) -> void:
	for state in match_state.players:
		if (state.role and state.role.id == "medium") or not state.alive:
			NetworkManager.send_to_peer(state.player.id, {"type": "secret_chat_message", "chat": "medium", "message": msg})
