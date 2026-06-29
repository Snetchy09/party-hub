extends BaseScreen

class_name GamePhaseUI

@onready var card_grid = $CardGrid
@onready var phase_container = $PhaseContainer
@onready var timer_label = $TimerLabel
@onready var network_manager = get_node("/root/NetworkManager")

var current_phase: String = ""
var my_player_state: GameSession.WWPlayerState

func _ready() -> void:
	network_manager.message_received.connect(_on_network_message)

func _on_network_message(from_id: int, message: Dictionary) -> void:
	match message["type"]:
		"phase_change":
			current_phase = message["phase"]
			match current_phase:
				"night":
					show_night_phase_ui(message["state"])
				"discussion":
					show_discussion_phase_ui(message["state"])
				"voting":
					show_voting_phase_ui(message["state"])
				"execution":
					show_execution_phase_ui(message)
				"game_end":
					show_game_end_ui(message)
		"timer_update":
			timer_label.text = "%.0f" % message["timer"]

func show_night_phase_ui(state: Dictionary) -> void:
	# Clear previous UI
	for child in phase_container.get_children():
		child.queue_free()
	
	# Get my role
	var my_card = state["cards"].filter(func(c): return c["player_id"] == PlayerManager.get_current_player().id)[0]
	var my_role_id = my_card["role"]
	
	# Show action UI based on role
	match my_role_id:
		"doctor":
			show_protect_ui(state)
		"werewolf":
			show_kill_ui(state)
		"blue_seer":
			show_investigate_ui(state)
		_:
			show_waiting_ui("Waiting for night to end...")

func show_waiting_ui(message: String) -> void:
	var label = Label.new()
	label.text = message
	phase_container.add_child(label)

func show_protect_ui(state: Dictionary) -> void:
	var title = Label.new()
	title.text = "Choose someone to protect"
	phase_container.add_child(title)
	
	for card_data in state["cards"]:
		if card_data["player_id"] == PlayerManager.get_current_player().id:
			continue
		if not card_data["alive"]:
			continue
		
		var btn = Button.new()
		btn.text = card_data["name"]
		btn.pressed.connect(func(): submit_action("protect", card_data["player_id"]))
		phase_container.add_child(btn)

func show_kill_ui(state: Dictionary) -> void:
	var title = Label.new()
	title.text = "Choose someone to kill"
	phase_container.add_child(title)
	
	for card_data in state["cards"]:
		if card_data["player_id"] == PlayerManager.get_current_player().id:
			continue
		if not card_data["alive"]:
			continue
		
		var btn = Button.new()
		btn.text = card_data["name"]
		btn.pressed.connect(func(): submit_action("kill", card_data["player_id"]))
		phase_container.add_child(btn)

func show_investigate_ui(state: Dictionary) -> void:
	var title = Label.new()
	title.text = "Choose someone to investigate"
	phase_container.add_child(title)
	
	for card_data in state["cards"]:
		if card_data["player_id"] == PlayerManager.get_current_player().id:
			continue
		if not card_data["alive"]:
			continue
		
		var btn = Button.new()
		btn.text = card_data["name"]
		btn.pressed.connect(func(): submit_action("investigate", card_data["player_id"]))
		phase_container.add_child(btn)

func show_voting_phase_ui(state: Dictionary) -> void:
	var title = Label.new()
	title.text = "Vote to eliminate someone"
	phase_container.add_child(title)
	
	for card_data in state["cards"]:
		if card_data["player_id"] == PlayerManager.get_current_player().id:
			continue
		if not card_data["alive"]:
			continue
		
		var btn = Button.new()
		btn.text = card_data["name"]
		btn.pressed.connect(func(): submit_vote(card_data["player_id"]))
		phase_container.add_child(btn)

func show_discussion_phase_ui(state: Dictionary) -> void:
	var label = Label.new()
	label.text = "Discuss and decide who to eliminate"
	phase_container.add_child(label)

func show_execution_phase_ui(message: Dictionary) -> void:
	var executed_id = message["executed_player_id"]
	var executed_name = message["state"]["cards"].filter(func(c): return c["player_id"] == executed_id)[0]["name"]
	
	var label = Label.new()
	label.text = "%s was eliminated!" % executed_name
	phase_container.add_child(label)

func show_game_end_ui(message: Dictionary) -> void:
	var label = Label.new()
	label.text = "Game Over! %s wins!\n%s" % [message["winner"].to_upper(), message["reason"]]
	phase_container.add_child(label)

func submit_action(action_type: String, target_id: int) -> void:
	network_manager.send_message(0, {
		"type": "action",
		"player_id": PlayerManager.get_current_player().id,
		"action_type": action_type,
		"target_id": target_id
	})
	
	var target_name = get_player_name(target_id)
	var label = Label.new()
	label.text = "Submitted: %s %s" % [action_type.to_upper(), target_name]
	phase_container.add_child(label)

func submit_vote(target_id: int) -> void:
	network_manager.send_message(0, {
		"type": "vote",
		"player_id": PlayerManager.get_current_player().id,
		"voted_for_id": target_id
	})
	
	var target_name = get_player_name(target_id)
	var label = Label.new()
	label.text = "Voted: %s" % target_name
	phase_container.add_child(label)

func get_player_name(player_id: int) -> String:
	for player in PlayerManager.get_all_players():
		if player.id == player_id:
			return player.name
	return "Unknown"
