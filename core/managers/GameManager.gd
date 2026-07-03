extends Node

var active_game_manager: WerewolvesGameManager = null

func start_werewolves_match(players: Array[PlayerData], settings: Dictionary) -> void:
	if not NetworkManager.is_host:
		return
	active_game_manager = WerewolvesGameManager.new()
	add_child(active_game_manager)
	NetworkManager.message_received.connect(_on_message_received)
	active_game_manager.start_game(players, settings)

func _on_message_received(sender_id: int, message: Dictionary) -> void:
	if active_game_manager and NetworkManager.is_host:
		active_game_manager.receive_action(sender_id, message)

func end_match() -> void:
	if active_game_manager:
		active_game_manager.queue_free()
		active_game_manager = null
