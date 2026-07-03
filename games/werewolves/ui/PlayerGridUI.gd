extends Control
class_name PlayerGridUI

signal card_selected(player_id: int)

var grid: GridContainer
var cards: Dictionary = {}
var card_scene := preload("res://games/werewolves/ui/PlayerCard.tscn")

func _ready() -> void:
	grid = GridContainer.new()
	grid.set_anchors_preset(Control.PRESET_FULL_RECT)
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	add_child(grid)

func update_from_state(card_states: Array) -> void:
	_set_columns(card_states.size())
	for data in card_states:
		var pid: int = data["player_id"]
		if not cards.has(pid):
			var card := card_scene.instantiate() as PlayerCard
			card.card_clicked.connect(_on_card_clicked)
			grid.add_child(card)
			cards[pid] = card
		cards[pid].update_from_state(data)

func set_cards_selectable(selectable: bool) -> void:
	for card in cards.values():
		card.set_selectable(selectable)

func _on_card_clicked(player_id: int) -> void:
	card_selected.emit(player_id)

func _set_columns(count: int) -> void:
	if count <= 5:
		grid.columns = 2
	elif count <= 8:
		grid.columns = 3
	elif count <= 12:
		grid.columns = 4
	else:
		grid.columns = 5
