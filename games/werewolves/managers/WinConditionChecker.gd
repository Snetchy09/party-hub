class_name WinConditionChecker
extends RefCounted

func check(match_state: WerewolvesMatch) -> Dictionary:
	var village_alive := 0
	var wolf_alive := 0

	for state in match_state.players:
		if not state.alive or state.role == null:
			continue
		match state.role.team:
			"village":
				village_alive += 1
			"werewolves":
				wolf_alive += 1
			"village_or_werewolves":
				if state.witch_type == "black":
					wolf_alive += 1
				else:
					village_alive += 1

	if wolf_alive == 0:
		var winners: Array[int] = []
		for state in match_state.players:
			if state.alive and state.role and state.role.team in ["village", "village_or_werewolves"]:
				winners.append(state.player.id)
		return {"winner": "village", "reason": "All werewolves have been eliminated.", "winners": winners}

	if wolf_alive >= village_alive and wolf_alive > 0:
		var winners: Array[int] = []
		for state in match_state.players:
			if state.alive and state.role and (state.role.team == "werewolves" or state.witch_type == "black"):
				winners.append(state.player.id)
		return {"winner": "werewolves", "reason": "The werewolves now control the village.", "winners": winners}

	return {"winner": "", "reason": "", "winners": []}
