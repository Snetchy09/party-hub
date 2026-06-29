extends Node

var games: Dictionary[String, GameManifest] = {}


func register_game(manifest: GameManifest) -> void:
	if manifest == null:
		return

	games[manifest.id] = manifest


func unregister_game(id: String) -> void:
	games.erase(id)


func get_game(id: String) -> GameManifest:
	return games.get(id)


func get_all_games() -> Array[GameManifest]:
	return games.values()


func has_game(id: String) -> bool:
	return games.has(id)
