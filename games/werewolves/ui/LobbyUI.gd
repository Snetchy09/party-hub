class_name LobbyUI
extends Control

var players_container: VBoxContainer
var ready_button: Button
var start_button: Button
var status_label: Label

var is_ready: bool = false
var is_host: bool = false
var players: Array[PlayerData] = []

signal game_started
signal ready_toggled(is_ready: bool)

func _ready() -> void:
	create_ui()

func create_ui() -> void:
	# Create main layout
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 10)
	add_child(main_vbox)
	
	# Title
	var title = Label.new()
	title.text = "WEREWOLVES LOBBY"
	title.add_theme_font_size_override("font_size", 32)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(title)
	
	# Status label
	status_label = Label.new()
	status_label.text = "Waiting for players..."
	status_label.add_theme_font_size_override("font_size", 20)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(status_label)
	
	# Players list
	players_container = VBoxContainer.new()
	main_vbox.add_child(players_container)
	
	# Buttons
	var button_hbox = HBoxContainer.new()
	button_hbox.add_theme_constant_override("separation", 10)
	
	ready_button = Button.new()
	ready_button.text = "Ready?"
	ready_button.pressed.connect(_on_ready_pressed)
	button_hbox.add_child(ready_button)
	
	start_button = Button.new()
	start_button.text = "START GAME"
	start_button.pressed.connect(_on_start_pressed)
	start_button.visible = is_host
	button_hbox.add_child(start_button)
	
	main_vbox.add_child(button_hbox)
	
	update_ui()

func add_player(player: PlayerData) -> void:
	players.append(player)
	update_ui()

func remove_player(player_id: int) -> void:
	players = players.filter(func(p): return p.id != player_id)
	update_ui()

func update_ui() -> void:
	if players_container == null:
		return
	
	# Clear players list
	for child in players_container.get_children():
		child.queue_free()
	
	# Add all players
	for player in players:
		var label = Label.new()
		label.text = player.name
		label.add_theme_font_size_override("font_size", 24)
		players_container.add_child(label)
	
	# Update status
	if is_host and players.size() >= 4:
		status_label.text = "Ready to start! (%d players)" % players.size()
		start_button.disabled = false
	elif is_host:
		status_label.text = "Need at least 4 players (%d/4)" % players.size()
		start_button.disabled = true
	else:
		status_label.text = "Waiting for host to start..."

func _on_ready_pressed() -> void:
	is_ready = !is_ready
	ready_button.text = "Ready (✓)" if is_ready else "Ready?"
	ready_toggled.emit(is_ready)

func _on_start_pressed() -> void:
	if is_host and players.size() >= 4:
		game_started.emit()
