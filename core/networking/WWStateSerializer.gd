class_name WWStateSerializer

static func build_for_player(match_state: WerewolvesMatch, viewer_id: int) -> Dictionary:
	var viewer := match_state.get_player_state(viewer_id)
	if viewer == null:
		return {}

	var cards := []
	for state in match_state.players:
		cards.append(_build_card(state, viewer))

	return {
		"phase": match_state.phase,
		"day": match_state.day_count,
		"timer": match_state.phase_timer,
		"my_player_id": viewer_id,
		"my_role": viewer.role.id if viewer.role else "",
		"my_role_display": viewer.role.display_name if viewer.role else "",
		"my_role_description": viewer.role.description if viewer.role else "",
		"my_team": viewer.role.team if viewer.role else "",
		"my_witch_type": viewer.witch_type,
		"my_ability_uses": viewer.night_uses_remaining,
		"my_can_act_night": viewer.role.can_act_at_night if viewer.role else false,
		"my_can_act_day": viewer.role.can_act_at_day if viewer.role else false,
		"my_status": viewer.statuses.duplicate(),
		"my_alive": viewer.alive,
		"can_use_ability": viewer.can_use_ability(),
		"cards": cards,
		"private_info": _build_private_info(viewer),
		"secret_chat_type": _get_chat_type(viewer, match_state),
	}

static func _build_card(state: WWPlayerState, viewer: WWPlayerState) -> Dictionary:
	var show_role := state.role_revealed

	if viewer.role and viewer.role.team == "werewolves" and state.role and state.role.team == "werewolves":
		show_role = true

	if viewer.role and viewer.role.id == "hacker" and state.player.id == viewer.hacked_target_id:
		show_role = true

	var public_statuses := []
	if state.statuses.get("jailed", false):
		public_statuses.append("jailed")

	return {
		"player_id": state.player.id,
		"name": state.player.display_name,
		"alive": state.alive,
		"avatar_data": state.player.avatar_data.to_dict() if state.player.avatar_data else {},
		"role": state.role.id if (show_role and state.role != null) else "",
		"role_display": state.role.display_name if (show_role and state.role != null) else "",
		"role_icon": state.role.icon if (show_role and state.role != null) else "",
		"role_revealed": show_role,
		"death_cause": state.death_cause if not state.alive else "",
		"statuses": public_statuses,
	}

static func _build_private_info(viewer: WWPlayerState) -> Dictionary:
	var info := {}
	if viewer.role == null:
		return info

	match viewer.role.id:
		"investigator":
			info["investigator_group"] = viewer.investigator_group
			info["latest_report"] = viewer.private_messages[-1]["text"] if viewer.private_messages.size() > 0 else ""
		"aura_seer":
			info["latest_report"] = viewer.private_messages[-1]["text"] if viewer.private_messages.size() > 0 else ""
		"hunter":
			info["hunter_target_id"] = viewer.hunter_target_id
		"witch":
			info["witch_type"] = viewer.witch_type
			info["uses_left"] = viewer.night_uses_remaining
		"hacker":
			info["hacked_target_id"] = viewer.hacked_target_id
		"jailer":
			info["kill_available"] = viewer.night_uses_remaining > 0
		"judge":
			info["skip_used"] = viewer.judge_skip_used
			info["free_used"] = viewer.judge_free_used
		"mirror":
			info["uses_left"] = viewer.mirror_uses

	return info

static func _get_chat_type(viewer: WWPlayerState, match_state: WerewolvesMatch) -> String:
	if viewer.role == null:
		return "none"
	if viewer.statuses.get("jailed", false):
		return "jailed"
	if viewer.role.id == "jailer" and match_state.phase == "night":
		return "jailer"
	if viewer.role.id == "medium":
		return "medium"
	if not viewer.alive:
		return "dead_with_medium"
	return "none"

static func build_reveal_all(match_state: WerewolvesMatch) -> Array:
	var cards := []
	for state in match_state.players:
		cards.append({
			"player_id": state.player.id,
			"name": state.player.display_name,
			"role": state.role.id if state.role else "",
			"role_display": state.role.display_name if state.role else "",
			"team": state.role.team if state.role else "",
			"alive": state.alive,
		})
	return cards
