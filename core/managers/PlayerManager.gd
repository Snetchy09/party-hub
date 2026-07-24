extends Node

var players: Dictionary = {}  # peer_id -> PlayerData
var local_settings: Dictionary = {}
var selected_game_id: String = "werewolves"

func reset() -> void:
	players.clear()

func add_player(peer_id: int, display_name: String, is_host: bool = false) -> void:
	var p := PlayerData.new(peer_id, display_name)
	p.is_host = is_host
	players[peer_id] = p

func remove_player(peer_id: int) -> void:
	players.erase(peer_id)

func get_all_players() -> Array[PlayerData]:
	var result: Array[PlayerData] = []
	for p in players.values():
		result.append(p)
	return result

func get_player(peer_id: int) -> PlayerData:
	return players.get(peer_id, null)

func get_current_player() -> PlayerData:
	var my_id := NetworkManager.get_my_peer_id()
	return get_player(my_id)
