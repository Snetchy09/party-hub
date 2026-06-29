extends Node

var match_manager: MatchManager
var phase_manager: PhaseManager
var game_phase_ui: GamePhaseUI
var role_reveal_ui: RoleRevealUI
var lobby_ui: LobbyUI
var current_screen: Control

var test_players: Array[WWPlayerState] = []
var my_player_index: int = 0

func _ready() -> void:
	# Create test players
	for i in range(4):
		var player = PlayerData.new()
		player.id = i
		player.name = "Player %d" % (i + 1)
		test_players.append(WWPlayerState.new(player))
	
	# Create managers
	match_manager = MatchManager.new()
	phase_manager = PhaseManager.new()
	phase_manager.match_manager = match_manager
	
	# Initialize match
	match_manager.initialize_match(test_players)
	
	print("\n=== PLAYERS CREATED ===")
	for player_state in test_players:
		print("%s -> %s" % [player_state.player.name, player_state.role.display_name])
	
	# Start with Lobby
	show_lobby()

func show_lobby() -> void:
	if current_screen:
		current_screen.queue_free()
	
	lobby_ui = LobbyUI.new()
	lobby_ui.is_host = true
	
	for player_state in test_players:
		lobby_ui.add_player(player_state.player)
	
	lobby_ui.game_started.connect(_on_lobby_game_started)
	
	add_child(lobby_ui)
	current_screen = lobby_ui
	
	print("\n=== LOBBY SCREEN ===")
	print("Click START GAME button to begin")

func _on_lobby_game_started() -> void:
	print("\n=== GAME STARTED ===")
	show_role_reveal()

func show_role_reveal() -> void:
	if current_screen:
		current_screen.queue_free()
	
	role_reveal_ui = RoleRevealUI.new()
	role_reveal_ui.set_my_role(test_players[my_player_index].role, test_players[my_player_index].player.id)
	role_reveal_ui.reveal_complete.connect(_on_role_reveal_complete)
	
	add_child(role_reveal_ui)
	current_screen = role_reveal_ui
	
	print("\n=== ROLE REVEAL SCREEN ===")
	print("You are: %s" % test_players[my_player_index].role.display_name)
	print("TAP THE CARD to reveal your role")

func _on_role_reveal_complete() -> void:
	my_player_index += 1
	
	if my_player_index < test_players.size():
		print("\n--- Next player turn ---")
		show_role_reveal()
	else:
		print("\n--- All players revealed ---")
		start_game_phase()

func start_game_phase() -> void:
	if current_screen:
		current_screen.queue_free()
	
	game_phase_ui = GamePhaseUI.new()
	game_phase_ui.set_managers(match_manager, phase_manager)
	game_phase_ui.my_player_id = test_players[0].player.id
	
	add_child(game_phase_ui)
	current_screen = game_phase_ui
	
	print("\n=== GAME PHASE STARTED ===")
	print("Starting Night 1...")
	
	# Start night phase
	phase_manager.start_night()
	update_game_ui()
	
	# Simulate game loop
	await get_tree().create_timer(3.0).timeout
	simulate_night_actions()

func simulate_night_actions() -> void:
	print("\n=== SIMULATING NIGHT ACTIONS ===")
	
	# Find doctor and werewolf
	var doctor: WWPlayerState = null
	var werewolf: WWPlayerState = null
	var target: WWPlayerState = null
	
	for player_state in test_players:
		if player_state.role.id == "doctor":
			doctor = player_state
		elif player_state.role.id == "werewolf":
			werewolf = player_state
		elif target == null and player_state.role.id == "villager":
			target = player_state
	
	# Submit actions
	if doctor and target:
		print("%s protects %s" % [doctor.player.name, target.player.name])
		phase_manager.submit_night_action(doctor.player.id, "protect", target.player.id)
	
	if werewolf and target:
		print("%s tries to kill %s" % [werewolf.player.name, target.player.name])
		phase_manager.submit_night_action(werewolf.player.id, "kill", target.player.id)
	
	# Wait for night to end
	await get_tree().create_timer(5.0).timeout
	phase_manager.end_night()
	print("\n=== NIGHT ENDED ===")
	update_game_ui()
	
	# Voting phase
	await get_tree().create_timer(3.0).timeout
	phase_manager.start_voting()
	update_game_ui()
	print("\n=== VOTING PHASE ===")
	
	# All vote for werewolf
	if werewolf:
		for player_state in test_players:
			if player_state.alive:
				phase_manager.submit_vote(player_state.player.id, werewolf.player.id)
	
	await get_tree().create_timer(3.0).timeout
	phase_manager.end_voting()
	update_game_ui()
	print("\n=== VOTING ENDED ===")

func update_game_ui() -> void:
	var state = match_manager.get_card_state()
	game_phase_ui.update_game_state(state)

func _process(delta: float) -> void:
	if match_manager and phase_manager:
		phase_manager._process(delta)
		if game_phase_ui:
			update_game_ui()
