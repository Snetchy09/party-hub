class_name WerewolvesMatch
extends RefCounted

var players: Array[WWPlayerState] = []
var phase: String = "lobby"     # "lobby" | "role_reveal" | "night" | "morning" | "discussion" | "voting" | "execution" | "ended"
var day_count: int = 0
var phase_timer: float = 0.0
var winner: String = ""         # "village" | "werewolves" | "jester" | "hunter" | "hacker" | ""
var win_reason: String = ""
var winners: Array[int] = []

func get_player_state(player_id: int) -> WWPlayerState:
	for state in players:
		if state.player.id == player_id:
			return state
	return null

func get_alive_players() -> Array[WWPlayerState]:
	return players.filter(func(s): return s.alive)

func get_alive_count_by_team(team: String) -> int:
	var count := 0
	for state in players:
		if state.alive and state.role and state.role.team == team:
			count += 1
	return count
