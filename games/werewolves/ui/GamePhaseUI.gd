extends Control

class_name GamePhaseUI

var card_grid: CardGridUI
var phase_container: VBoxContainer
var timer_label: Label

var current_phase: String = ""
var my_player_id: int = -1
var match_manager: MatchManager
var phase_manager: PhaseManager

signal action_submitted(action_type: String, target_id: int)
signal vote_submitted(voted_for_id: int)

func _ready() -> void:
	# Setup layout
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	
	# Timer at top
	timer_label = Label.new()
	timer_label.add_theme_font_size_override("font_size", 32)
	timer_label.alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(timer_label)
	
	# Card grid
	card_grid = CardGridUI.new()
	card_grid.custom_minimum_size = Vector2(0, 300)
	vbox.add_child(card_grid)
	
	# Phase-specific UI
	phase_container = VBoxContainer.new()
	phase_container.custom_minimum_size = Vector2(0, 200)
	vbox.add_child(phase_container)
	
	add_child(vbox)

func set_managers(mm: MatchManager, pm: PhaseManager) -> void:
	match_manager = mm
	phase_manager = pm

func update_game_state(state: Dictionary) -> void:
	current_phase = state["phase"]
	
	# Update card grid
	card_grid.update_cards(state["cards"])
	
	# Update timer
	if state.has("timer"):
		timer_label.text = "%.0f" % state["timer"]
	
	# Update phase-specific UI
	match current_phase:
		"night":
			show_night_ui(state)
		"voting":
			show_voting_ui(state)
		"morning", "discussion":
			show_waiting_ui(state)
		"execution":
			show_execution_ui(state)
		"game_end":
			show_game_end_ui(state)

func show_night_ui(state: Dictionary) -> void:
	phase_container.clear()
	
	var my_card = state["cards"].filter(func(c): return c["player_id"] == my_player_id)
	if my_card.is_empty():
		return
	
	var my_role = my_card[0]["role"]
	
	# Check if I have a night ability
	var has_ability = my_role in ["doctor", "werewolf", "blue_seer"]
	
	if not has_ability:
		var label = Label.new()
		label.text = "Waiting for night to end..."
		label.add_theme_font_size_override("font_size", 24)
		phase_container.add_child(label)
		return
	
	# Show action buttons
	var title = Label.new()
	match my_role:
		"doctor":
			title.text = "Choose who to PROTECT"
		"werewolf":
			title.text = "Choose who to KILL"
		"blue_seer":
			title.text = "Choose who to INVESTIGATE"
	title.add_theme_font_size_override("font_size", 20)
	phase_container.add_child(title)
	
	var button_container = GridContainer.new()
	button_container.columns = 2
	
	for card_data in state["cards"]:
		if card_data["player_id"] == my_player_id:
			continue
		if not card_data["alive"]:
			continue
		
		var btn = Button.new()
		btn.text = card_data["name"]
		btn.pressed.connect(func(): _submit_night_action(my_role, card_data["player_id"]))
		button_container.add_child(btn)
	
	phase_container.add_child(button_container)

func show_voting_ui(state: Dictionary) -> void:
	phase_container.clear()
	
	var title = Label.new()
	title.text = "Vote to ELIMINATE"
	title.add_theme_font_size_override("font_size", 20)
	phase_container.add_child(title)
	
	var button_container = GridContainer.new()
	button_container.columns = 2
	
	for card_data in state["cards"]:
		if card_data["player_id"] == my_player_id:
			continue
		if not card_data["alive"]:
			continue
		
		var btn = Button.new()
		btn.text = card_data["name"]
		btn.pressed.connect(func(): _submit_vote(card_data["player_id"]))
		button_container.add_child(btn)
	
	phase_container.add_child(button_container)

func show_waiting_ui(state: Dictionary) -> void:
	phase_container.clear()
	
	var label = Label.new()
	match current_phase:
		"morning":
			label.text = "Morning - Review results"
		"discussion":
			label.text = "DISCUSS who to eliminate"
	label.add_theme_font_size_override("font_size", 24)
	phase_container.add_child(label)

func show_execution_ui(state: Dictionary) -> void:
	phase_container.clear()
	
	var label = Label.new()
	label.text = "Player was executed!"
	label.add_theme_font_size_override("font_size", 24)
	label.modulate = Color.RED
	phase_container.add_child(label)

func show_game_end_ui(state: Dictionary) -> void:
	phase_container.clear()
	
	var label = Label.new()
	label.text = "GAME OVER"
	label.add_theme_font_size_override("font_size", 32)
	label.modulate = Color.YELLOW
	phase_container.add_child(label)

func _submit_night_action(role: String, target_id: int) -> void:
	var action_type = ""
	match role:
		"doctor":
			action_type = "protect"
		"werewolf":
			action_type = "kill"
		"blue_seer":
			action_type = "investigate"
	
	phase_manager.submit_night_action(my_player_id, action_type, target_id)
	
	var label = Label.new()
	label.text = "Action submitted!"
	label.add_theme_font_size_override("font_size", 18)
	phase_container.add_child(label)

func _submit_vote(target_id: int) -> void:
	phase_manager.submit_vote(my_player_id, target_id)
	
	var label = Label.new()
	label.text = "Vote submitted!"
	label.add_theme_font_size_override("font_size", 18)
	phase_container.add_child(label)
