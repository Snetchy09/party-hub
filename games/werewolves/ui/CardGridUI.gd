extends Control

class_name CardGridUI

@onready var card_container = $GridContainer
var card_prefab = preload("res://games/werewolves/ui/PlayerCard.tscn")
var cards: Dictionary = {}  # player_id -> card node
var network_manager: NetworkManager

func _ready() -> void:
	network_manager = get_node("/root/NetworkManager")
	
	# Subscribe to state updates
	network_manager.message_received.connect(_on_network_message)

func _on_network_message(from_id: int, message: Dictionary) -> void:
	match message["type"]:
		"phase_change", "timer_update":
			if message.has("state"):
				update_card_grid(message["state"]["cards"])

func update_card_grid(card_states: Array) -> void:
	# Adjust grid columns based on player count
	var player_count = card_states.size()
	var columns = clamp(player_count / 2, 2, 5)  # 2-5 columns
	card_container.columns = columns
	
	for card_data in card_states:
		var player_id = card_data["player_id"]
		
		if not cards.has(player_id):
			# Create new card
			var card = card_prefab.instantiate()
			card_container.add_child(card)
			cards[player_id] = card
		
		# Update existing card
		var card = cards[player_id]
		card.update_data(card_data)
