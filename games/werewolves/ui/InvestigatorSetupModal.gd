extends Control

@onready var selected_label: Label = $CenterContainer/Panel/MarginContainer/VBox/SelectedLabel
@onready var player_grid: PlayerGridUI = $CenterContainer/Panel/MarginContainer/VBox/PlayerGrid
@onready var confirm_button: Button = $CenterContainer/Panel/MarginContainer/VBox/ConfirmButton

var selected_ids: Array[int] = []
var latest_cards: Array = []

func _ready() -> void:
	player_grid.card_selected.connect(_on_card_selected)
	confirm_button.pressed.connect(_on_confirm)
	confirm_button.disabled = true
	NetworkManager.message_received.connect(_on_message)

func _on_message(_sender_id: int, message: Dictionary) -> void:
	if message.get("type", "") == "state_update":
		latest_cards = message["state"].get("cards", [])
		player_grid.update_from_state(latest_cards)
		player_grid.set_cards_selectable(true)

func _on_card_selected(player_id: int) -> void:
	if player_id in selected_ids:
		selected_ids.erase(player_id)
	elif selected_ids.size() < 3:
		selected_ids.append(player_id)

	selected_label.text = "Selected: %d/3" % selected_ids.size()
	confirm_button.disabled = selected_ids.size() != 3

func _on_confirm() -> void:
	NetworkManager.send_to_host({"type": "investigator_group", "group": selected_ids})
	queue_free()
