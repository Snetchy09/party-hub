class_name WerewolvesMatch
extends RefCounted

var players: Array[WWPlayerState] = []

var phase: WerewolvesGameManager.Phase = WerewolvesGameManager.Phase.LOBBY

var day: int = 1
var night: int = 0

var winner_team: String = ""

var settings := {}

func get_alive_players() -> Array[WWPlayerState]:
	var alive: Array[WWPlayerState] = []

	for player in players:
		if player.alive:
			alive.append(player)

	return alive


func get_dead_players() -> Array[WWPlayerState]:
	var dead: Array[WWPlayerState] = []

	for player in players:
		if !player.alive:
			dead.append(player)

	return dead
