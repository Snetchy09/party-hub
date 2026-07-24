extends Node

var active_game_id: String = ""
var active_game_manager: Node = null

## Registry of game_id -> a Callable that builds and returns that game's manager node.
## Adding a new game means adding ONE line here — nothing else in this file changes.
var _game_manager_factories: Dictionary = {
	"werewolves": func(): return WerewolvesGameManager.new(),
}

func start_match(game_id: String, players: Array[PlayerData], settings: Dictionary) -> void:
	if not NetworkManager.is_host:
		return
	if not _game_manager_factories.has(game_id):
		push_error("GameManager: no factory registered for game_id '%s'" % game_id)
		return

	active_game_id = game_id
	active_game_manager = _game_manager_factories[game_id].call()
	add_child(active_game_manager)
	NetworkManager.message_received.connect(_on_message_received)
	active_game_manager.start_game(players, settings)

func _on_message_received(sender_id: int, message: Dictionary) -> void:
	if active_game_manager and NetworkManager.is_host and active_game_manager.has_method("receive_action"):
		active_game_manager.receive_action(sender_id, message)

func end_match() -> void:
	if active_game_manager:
		active_game_manager.queue_free()
		active_game_manager = null
	active_game_id = ""
