class_name NightActionResolver
extends RefCounted

func resolve(match_state: WerewolvesMatch, pending_actions: Array[Dictionary]) -> Array[Dictionary]:
	var events: Array[Dictionary] = []

	var actions_by_actor: Dictionary = {}
	for action in pending_actions:
		actions_by_actor[action["actor_id"]] = action

	_resolve_jailer_kill(match_state, actions_by_actor, events)
	var reflected_actors: Dictionary = _build_reflection_set(match_state, actions_by_actor, events)
	var protected_ids: Dictionary = _resolve_protects(match_state, actions_by_actor, reflected_actors, events)
	_resolve_werewolf_kills(match_state, actions_by_actor, protected_ids, reflected_actors, events)
	_resolve_witch(match_state, actions_by_actor, reflected_actors, events)
	_resolve_aura_seer(match_state, actions_by_actor, reflected_actors, events)
	_resolve_hacker_ability(match_state, actions_by_actor, protected_ids, events)
	_resolve_streets_lady(match_state, actions_by_actor, events)
	_resolve_bloody_seer(match_state, actions_by_actor, events)
	_resolve_medium_revive(match_state, actions_by_actor, events)
	_resolve_investigator_report(match_state, events)

	for state in match_state.players:
		state.tick_statuses()

	_resolve_hacker_target_death(match_state, events)

	return events


func _resolve_jailer_kill(match_state: WerewolvesMatch, actions: Dictionary, events: Array[Dictionary]) -> void:
	for actor_id in actions:
		var action = actions[actor_id]
		if action["action_type"] != "jail_kill":
			continue
		var jailer := match_state.get_player_state(actor_id)
		if jailer == null or not jailer.alive or jailer.night_uses_remaining <= 0:
			continue
		for state in match_state.players:
			if state.statuses.get("jailed", false) and state.alive:
				state.alive = false
				state.death_cause = "jailer"
				state.role_revealed = false
				jailer.consume_use()
				events.append({"type": "death", "player_id": state.player.id, "cause": "jailer"})
				break


func _build_reflection_set(match_state: WerewolvesMatch, actions: Dictionary, events: Array[Dictionary]) -> Dictionary:
	var reflected: Dictionary = {}

	for actor_id in actions:
		var action = actions[actor_id]
		if action["action_type"] != "reflect":
			continue
		var mirror_state := match_state.get_player_state(actor_id)
		if mirror_state == null or not mirror_state.alive or mirror_state.mirror_uses <= 0:
			continue

		var mirror_target_id: int = action["target_id"]

		for other_actor_id in actions:
			if other_actor_id == actor_id:
				continue
			var other_action = actions[other_actor_id]
			if other_action.get("target_id", -1) == mirror_target_id:
				reflected[other_actor_id] = mirror_target_id
				mirror_state.mirror_uses -= 1
				events.append({
					"type": "mirror_reflect",
					"mirror_id": actor_id,
					"reflected_actor_id": other_actor_id,
				})
				break

	return reflected


func _resolve_protects(match_state: WerewolvesMatch, actions: Dictionary, reflected: Dictionary, events: Array[Dictionary]) -> Dictionary:
	var protected_ids: Dictionary = {}

	for actor_id in actions:
		var action = actions[actor_id]
		if action["action_type"] != "protect":
			continue
		var doctor := match_state.get_player_state(actor_id)
		if doctor == null or not doctor.alive:
			continue
		if doctor.statuses.get("cursed", 0) > 0:
			continue

		var target_id: int = action["target_id"]
		if reflected.has(actor_id):
			target_id = reflected[actor_id]

		var target_state := match_state.get_player_state(target_id)
		if target_state:
			target_state.statuses["protected"] = true
			protected_ids[target_id] = true
			events.append({"type": "protect", "doctor_id": actor_id, "target_id": target_id})

	return protected_ids


func _resolve_werewolf_kills(match_state: WerewolvesMatch, actions: Dictionary, protected_ids: Dictionary, reflected: Dictionary, events: Array[Dictionary]) -> void:
	var kill_votes: Dictionary = {}

	for actor_id in actions:
		var action = actions[actor_id]
		if action["action_type"] != "kill":
			continue
		var wolf := match_state.get_player_state(actor_id)
		if wolf == null or not wolf.alive:
			continue
		if wolf.statuses.get("cursed", 0) > 0:
			continue

		var target_id: int = action["target_id"]

		if reflected.has(actor_id):
			wolf.alive = false
			wolf.death_cause = "reflected"
			wolf.role_revealed = true
			events.append({"type": "death", "player_id": actor_id, "cause": "reflected"})
			continue

		kill_votes[target_id] = kill_votes.get(target_id, 0) + 1

	if kill_votes.is_empty():
		return

	var chosen_target := -1
	var max_votes := 0
	for tid in kill_votes:
		if kill_votes[tid] > max_votes:
			chosen_target = tid
			max_votes = kill_votes[tid]

	if chosen_target == -1:
		return

	var target_state := match_state.get_player_state(chosen_target)
	if target_state == null or not target_state.alive:
		return

	if protected_ids.has(chosen_target):
		events.append({"type": "kill_blocked", "target_id": chosen_target})
		return

	target_state.alive = false
	target_state.death_cause = "night_kill"
	target_state.role_revealed = true
	events.append({"type": "death", "player_id": chosen_target, "cause": "night_kill"})


func _resolve_witch(match_state: WerewolvesMatch, actions: Dictionary, reflected: Dictionary, events: Array[Dictionary]) -> void:
	for actor_id in actions:
		var action = actions[actor_id]
		if action["action_type"] not in ["witch_bless", "witch_curse"]:
			continue
		var witch := match_state.get_player_state(actor_id)
		if witch == null or not witch.alive or witch.night_uses_remaining <= 0:
			continue

		var target_id: int = action["target_id"]
		if reflected.has(actor_id):
			target_id = reflected[actor_id]

		var target_state := match_state.get_player_state(target_id)
		if target_state == null:
			continue

		if action["action_type"] == "witch_bless" and witch.witch_type == "white":
			target_state.statuses["blessed"] = true
			witch.consume_use()
			events.append({"type": "bless", "target_id": target_id})
		elif action["action_type"] == "witch_curse" and witch.witch_type == "black":
			target_state.statuses["cursed"] = 3
			witch.consume_use()
			events.append({"type": "curse", "target_id": target_id})


func _resolve_aura_seer(match_state: WerewolvesMatch, actions: Dictionary, reflected: Dictionary, events: Array[Dictionary]) -> void:
	for actor_id in actions:
		var action = actions[actor_id]
		if action["action_type"] != "investigate":
			continue
		var seer := match_state.get_player_state(actor_id)
		if seer == null or not seer.alive:
			continue
		if seer.statuses.get("cursed", 0) > 0:
			continue

		var target_id: int = action["target_id"]
		var result_text := ""

		if reflected.has(actor_id):
			result_text = "unknown (your vision blurs strangely)"
		else:
			var target_state := match_state.get_player_state(target_id)
			if target_state and target_state.role:
				result_text = target_state.role.appears_as

		seer.private_messages.append({
			"day": match_state.day_count,
			"text": "You sensed that %s appears %s." % [_get_name(match_state, target_id), result_text],
		})
		events.append({"type": "investigate_result", "seer_id": actor_id, "target_id": target_id, "result": result_text})


func _resolve_hacker_ability(match_state: WerewolvesMatch, actions: Dictionary, protected_ids: Dictionary, events: Array[Dictionary]) -> void:
	for actor_id in actions:
		var action = actions[actor_id]
		if action["action_type"] != "hack_use":
			continue
		var hacker := match_state.get_player_state(actor_id)
		if hacker == null or not hacker.alive or hacker.hacked_target_id == -1:
			continue

		var hacked_state := match_state.get_player_state(hacker.hacked_target_id)
		if hacked_state == null or not hacked_state.alive or hacked_state.role == null:
			continue

		var sub_target_id: int = action.get("target_id", -1)
		if hacked_state.role.night_action == "kill" and sub_target_id != -1:
			var sub_target := match_state.get_player_state(sub_target_id)
			if sub_target and sub_target.alive and not protected_ids.has(sub_target_id):
				sub_target.alive = false
				sub_target.death_cause = "night_kill"
				sub_target.role_revealed = true
				events.append({"type": "death", "player_id": sub_target_id, "cause": "night_kill"})

		events.append({"type": "hack_used", "hacker_id": actor_id, "hacked_id": hacker.hacked_target_id})


func _resolve_streets_lady(match_state: WerewolvesMatch, actions: Dictionary, events: Array[Dictionary]) -> void:
	for actor_id in actions:
		var action = actions[actor_id]
		if action["action_type"] != "visit":
			continue
		var lady := match_state.get_player_state(actor_id)
		if lady == null or not lady.alive:
			continue
		var target_id: int = action["target_id"]
		lady.statuses["visited"] = target_id
		events.append({"type": "visit", "lady_id": actor_id, "target_id": target_id})


func _resolve_bloody_seer(match_state: WerewolvesMatch, actions: Dictionary, events: Array[Dictionary]) -> void:
	for actor_id in actions:
		var action = actions[actor_id]
		if action["action_type"] != "sacrifice":
			continue
		var seer := match_state.get_player_state(actor_id)
		if seer == null or not seer.alive or seer.night_uses_remaining <= 0:
			continue

		var sacrifice_id: int = action["target_id"]
		var sacrifice_state := match_state.get_player_state(sacrifice_id)
		if sacrifice_state == null or not sacrifice_state.alive:
			continue

		sacrifice_state.alive = false
		sacrifice_state.death_cause = "sacrifice"
		sacrifice_state.role_revealed = true
		seer.consume_use()
		events.append({"type": "death", "player_id": sacrifice_id, "cause": "sacrifice"})

		var bad_players := match_state.players.filter(func(s):
			return s.alive and s.role and s.role.appears_as == "bad" and not s.role_revealed
		)
		if bad_players.size() > 0:
			bad_players.shuffle()
			var revealed : WWPlayerState= bad_players[0]
			revealed.role_revealed = true
			events.append({"type": "reveal", "player_id": revealed.player.id, "role": revealed.role.id})


func _resolve_medium_revive(match_state: WerewolvesMatch, actions: Dictionary, events: Array[Dictionary]) -> void:
	for actor_id in actions:
		var action = actions[actor_id]
		if action["action_type"] != "revive":
			continue
		var medium := match_state.get_player_state(actor_id)
		if medium == null or not medium.alive or medium.medium_revived:
			continue

		var target_id: int = action["target_id"]
		var target_state := match_state.get_player_state(target_id)
		if target_state == null or target_state.alive:
			continue

		target_state.alive = true
		target_state.death_cause = ""
		medium.medium_revived = true
		medium.night_uses_remaining = 0
		events.append({"type": "revive", "player_id": target_id})


func _resolve_investigator_report(match_state: WerewolvesMatch, events: Array[Dictionary]) -> void:
	for state in match_state.players:
		if state.role == null or state.role.id != "investigator" or not state.alive:
			continue
		if state.investigator_group.is_empty():
			continue

		var kills_in_group := 0
		var killer_revealed_id := -1

		for event in events:
			if event.get("type") != "death":
				continue
			if event.get("cause") != "night_kill":
				continue
			var victim_id: int = event["player_id"]
			var victim_in_group := victim_id in state.investigator_group

			var wolf_in_group := false
			for pid in state.investigator_group:
				var p_state := match_state.get_player_state(pid)
				if p_state and p_state.role and p_state.role.team == "werewolves":
					wolf_in_group = true
					killer_revealed_id = pid

			if victim_in_group:
				kills_in_group += 1
				if not wolf_in_group:
					killer_revealed_id = -1

		var report_text := "%d player(s) in your group acted violently last night." % kills_in_group
		if killer_revealed_id != -1:
			var killer_state := match_state.get_player_state(killer_revealed_id)
			if killer_state and killer_state.role:
				report_text += " You discovered: %s is the %s!" % [_get_name(match_state, killer_revealed_id), killer_state.role.display_name]

		state.private_messages.append({"day": match_state.day_count, "text": report_text})


func _resolve_hacker_target_death(match_state: WerewolvesMatch, events: Array[Dictionary]) -> void:
	for state in match_state.players:
		if state.role == null or state.role.id != "hacker" or not state.alive:
			continue
		if state.hacked_target_id == -1:
			continue

		var days_hacked := match_state.day_count - state.hacked_target_start_day
		if days_hacked >= 1:
			var target_state := match_state.get_player_state(state.hacked_target_id)
			if target_state and target_state.alive:
				target_state.alive = false
				target_state.death_cause = "hacker"
				target_state.role_revealed = false
				events.append({"type": "death", "player_id": state.hacked_target_id, "cause": "hacker"})

			state.hacked_target_id = -1


func _get_name(match_state: WerewolvesMatch, player_id: int) -> String:
	var s := match_state.get_player_state(player_id)
	return s.player.display_name if s else "Unknown"
