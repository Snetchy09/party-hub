extends Node

class_name WerewolvesGameManager

var network_manager: NetworkManager
var game_session: GameSession
var phase_controller: PhaseController
var player_manager: PlayerManager

func _ready() -> void:
	# Create core systems
	game_session = GameSession.new()
	phase_controller = PhaseController.new()
	phase_controller.game_session = game_session
	phase_controller.network_manager = network_manager
	
	add_child(phase_controller)
	
	# Subscribe to network events
	network_manager.message_received.connect(_on_network_message)
	network_manager.client_connected.connect(_on_client_connected)

func _on_client_connected(peer_id: int, player_name: String) -> void:
	print("Host: Client connected - %s (%d)" % [player_name, peer_id])
	
	# Add player to game session
	var player = PlayerData.new()
	player.id = peer_id
	player.name = player_name
	
	game_session.players.append(player)
	
	# Create player state
	var state = GameSession.WWPlayerState.new()
	state.player_id = peer_id
	state.player = player
	game_session.player_states[peer_id] = state
	
	# Broadcast to all clients: new player joined
	network_manager.broadcast_to_all({
		"type": "player_joined",
		"player_name": player_name,
		"total_players": game_session.players.size()
	})

func _on_network_message(from_id: int, message: Dictionary) -> void:
	match message["type"]:
		"player_ready":
			print("Player %d ready" % from_id)
		"action":
			game_session.receive_action(message["player_id"], message["action_type"], message["target_id"])
		"vote":
			game_session.receive_vote(message["player_id"], message["voted_for_id"])

func start_game() -> void:
	# Initialize match with all players
	game_session.initialize_match(game_session.players)
	
	# Broadcast to all: game starting
	network_manager.broadcast_to_all({
		"type": "game_started"
	})
	
	# Start phase controller
	phase_controller.start_game()
