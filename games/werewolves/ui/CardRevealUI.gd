extends BaseScreen

class_name CardRevealUI

@onready var card = $Card
var my_role: RoleData
var network_manager: NetworkManager

func _ready() -> void:
	network_manager = get_node("/root/NetworkManager")
	
	# Subscribe to network messages
	network_manager.message_received.connect(_on_network_message)
	
	# Get my role from game session (need to broadcast this to clients)
	# For now, we'll wait for host to send it
	
	card.gui_input.connect(_on_card_input)

func _on_network_message(from_id: int, message: Dictionary) -> void:
	match message["type"]:
		"reveal_my_role":
			my_role = RoleDatabase.get_role(message["role_id"])
			card.show_ready_to_tap()

func _on_card_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		flip_to_role()

func flip_to_role() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Float upward
	tween.tween_property(card, "position:y", card.position.y - 50, 0.3)
	
	# Rotate 180 degrees
	tween.tween_property(card, "rotation:y", TAU / 2, 0.5)
	
	await tween.finished
	
	card.display_role(my_role)
	
	# Wait 2 seconds, then flip back
	await get_tree().create_timer(2.0).timeout
	
	flip_to_hidden()

func flip_to_hidden() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(card, "rotation:y", TAU, 0.5)
	tween.tween_property(card, "position:y", card.position.y + 50, 0.3)
	
	await tween.finished
	
	card.reset_to_hidden()
	
	# Wait for all players to reveal (broadcast from host)
	# Then go to night phase
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://games/werewolves/ui/GamePhaseUI.tscn")
