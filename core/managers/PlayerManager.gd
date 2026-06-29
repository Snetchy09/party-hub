extends Node

signal player_added(player: PlayerData)
signal player_removed(player_id: int)
signal player_updated(player: PlayerData)

var _players: Dictionary = {}


func add_player(player: PlayerData) -> void:
	_players[player.id] = player
	player_added.emit(player)


func remove_player(id: int) -> void:
	if !_players.has(id):
		return

	_players.erase(id)
	player_removed.emit(id)


func get_player(id: int) -> PlayerData:
	return _players.get(id)


func get_players() -> Array[PlayerData]:
	var result: Array[PlayerData] = []

	for player in _players.values():
		result.append(player)

	return result


func clear() -> void:
	_players.clear()
