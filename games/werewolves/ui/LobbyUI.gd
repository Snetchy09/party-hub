extends BaseScreen

class_name WerewolvesLobbyUI

@onready var players_list = $PlayersList
@onready var ready_button = $ReadyButton
@onready var status_label = $StatusLabel

var network_manager: NetworkManager
var is_ready: bool = false

func _ready() -> void:
	network_manager = get_node("/root/NetworkManager")
	
	# Subscribe to network events
	network_manager.message_received.connect(_on_network_message)
	
	ready_button.pressed.connect(_on_ready_clicked)
	
	# Add self to players list
	add_player_to_list(PlayerManager.get_current_player().name)
	
	status_label.text = "Waiting for players..."

func _on_network_message(from_id: int, message: Dictionary) -> void:
	match message["type"]:
		"player_joined":
			add_player_to_list(message["player_name"])
		"game_started":
			# Host started the game, go to card reveal screen
			get_tree().change_scene_to_file("res://games/werewolves/ui/CardRevealUI.tscn")

func add_player_to_list(player_name: String) -> void:
	var label = Label.new()
	label.text = player_name
	players_list.add_child(label)
	print("Added player to lobby: %s" % player_name)

func _on_ready_clicked() -> void:
	is_ready = !is_ready
	ready_button.text = "Ready (Waiting for host to start)" if is_ready else "Ready?"
	
	# Notify host
	network_manager.send_message(0, {
		"type": "player_ready",
		"player_id": PlayerManager.get_current_player().id,
		"is_ready": is_ready
	})
