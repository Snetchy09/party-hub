class_name VoteManager
extends RefCounted

signal jester_won(player_id: int)
signal hunter_won(hunter_id: int, target_id: int)

var votes: Dictionary = {}

func reset() -> void:
	votes.clear()

func submit_vote(voter_id: int, target_id: int, match_state: WerewolvesMatch) -> void:
	var voter_state := match_state.get_player_state(voter_id)
	if voter_state == null or not voter_state.alive:
		return
	votes[voter_id] = target_id

func get_public_vote_counts(match_state: WerewolvesMatch) -> Dictionary:
	return _count_votes(match_state)

func _count_votes(match_state: WerewolvesMatch) -> Dictionary:
	var effective_votes: Dictionary = {}

	var hacker_vote_target := -1
	var hacked_player_id := -1
	for state in match_state.players:
		if state.role and state.role.id == "hacker" and state.alive and state.hacked_target_id != -1:
			hacked_player_id = state.hacked_target_id
			hacker_vote_target = votes.get(state.player.id, -1)

	for voter_id in votes:
		var target = votes[voter_id]
		if voter_id == hacked_player_id and hacker_vote_target != -1:
			target = hacker_vote_target
		effective_votes[voter_id] = target

	var counts: Dictionary = {}
	for voter_id in effective_votes:
		var target = effective_votes[voter_id]
		counts[target] = counts.get(target, 0) + 1
	return counts

func resolve_execution(match_state: WerewolvesMatch) -> Dictionary:
	var counts := _count_votes(match_state)
	if counts.is_empty():
		return {"executed_id": -1, "was_tie": false}

	var max_votes := 0
	var candidates: Array[int] = []
	for pid in counts:
		if counts[pid] > max_votes:
			max_votes = counts[pid]
			candidates = [pid]
		elif counts[pid] == max_votes and max_votes > 0:
			candidates.append(pid)

	if candidates.is_empty():
		return {"executed_id": -1, "was_tie": false}

	var was_tie := candidates.size() > 1
	candidates.shuffle()
	var executed_id: int = candidates[0]

	var executed_state := match_state.get_player_state(executed_id)
	if executed_state == null:
		return {"executed_id": -1, "was_tie": was_tie}

	if executed_state.role and executed_state.role.id == "jester":
		jester_won.emit(executed_id)
		return {"executed_id": executed_id, "was_tie": was_tie, "jester_win": true}

	for state in match_state.players:
		if state.role and state.role.id == "hunter" and state.alive:
			if state.hunter_target_id == executed_id:
				hunter_won.emit(state.player.id, executed_id)

	executed_state.alive = false
	executed_state.role_revealed = true
	executed_state.death_cause = "voted_out"

	return {"executed_id": executed_id, "was_tie": was_tie}
