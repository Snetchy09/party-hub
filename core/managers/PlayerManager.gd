extends Node

var current_player: PlayerData
var all_players: Array[PlayerData] = []
var players_by_id: Dictionary = {}
var is_host: bool = false
var peer_id: int = -1

func initialize(is_host: bool, player_name: String) -> void:
	self.is_host = is_host
	current_player = PlayerData.new()
	current_player.name = player_name
	current_player.id = randi_range(1, 1000000)
	
	all_players.append(current_player)
	players_by_id[current_player.id] = current_player

func add_player(player_id: int, player_name: String) -> void:
	var player = PlayerData.new()
	player.id = player_id
	player.name = player_name
	all_players.append(player)
	players_by_id[player_id] = player
	print("Added player: %s (%d)" % [player_name, player_id])

func get_player(player_id: int) -> PlayerData:
	return players_by_id.get(player_id)

func get_all_players() -> Array[PlayerData]:
	return all_players

func get_current_player() -> PlayerData:
	return current_player
