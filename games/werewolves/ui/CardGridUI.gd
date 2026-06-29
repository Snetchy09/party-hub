extends Control

class_name CardGridUI

@onready var grid_container = GridContainer.new()
var card_scene = preload("res://games/werewolves/ui/PlayerCard.tscn")
var cards: Dictionary = {}  # player_id -> PlayerCard node

func _ready() -> void:
	grid_container.columns = 2
	add_child(grid_container)

func update_cards(card_states: Array) -> void:
	# Adjust grid columns based on player count
	var player_count = card_states.size()
	match player_count:
		4, 5:
			grid_container.columns = 2
		6, 7, 8:
			grid_container.columns = 3
		9, 10, 11, 12:
			grid_container.columns = 4
		_:
			grid_container.columns = 5
	
	# Update or create cards
	for card_data in card_states:
		var player_id = card_data["player_id"]
		
		if not cards.has(player_id):
			var card = card_scene.instantiate() as PlayerCard
			grid_container.add_child(card)
			cards[player_id] = card
		
		var card = cards[player_id]
		card.update_from_state(card_data)

func get_card_size() -> Vector2:
	if grid_container.columns <= 2:
		return Vector2(150, 200)
	elif grid_container.columns <= 3:
		return Vector2(120, 160)
	else:
		return Vector2(100, 140)
