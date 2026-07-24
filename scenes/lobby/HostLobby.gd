extends BaseScreen

@onready var ip_label: Label = $MarginContainer/VBoxContainer/IPPanel/IPLabel
@onready var player_count_label: Label = $MarginContainer/VBoxContainer/PlayerCountLabel
@onready var player_list_container: VBoxContainer = $MarginContainer/VBoxContainer/PlayerListContainer
@onready var game_settings_container: Control = $MarginContainer/VBoxContainer/GameSettingsContainer
@onready var start_button: Button = $MarginContainer/VBoxContainer/StartButton
@onready var back_button: Button = $MarginContainer/VBoxContainer/BackButton

const MIN_PLAYERS := 1

var current_manifest: GameManifest
var settings_panel: Control = null

func _ready() -> void:
	current_manifest = GameRegistry.get_game(PlayerManager.selected_game_id)
	if current_manifest == null:
		ip_label.text = "Error: game not found."
		return

	_load_settings_panel()

	var err := NetworkManager.create_server()
	if err != OK:
		ip_label.text = "Failed to host. Check network settings."
		return

	ip_label.text = "IP: %s   Port: %s" % [NetworkManager.get_local_ip_guess(), NetworkManager.PORT]

	NetworkManager.client_connected.connect(_on_client_connected)
	NetworkManager.client_disconnected.connect(_on_client_disconnected)
	NetworkManager.message_received.connect(_on_message_received)

	PlayerManager.reset()
	PlayerManager.add_player(1, SettingsManager.player_name, true)
	PlayerManager.get_player(1).avatar_data = SettingsManager.avatar_data

	start_button.pressed.connect(_on_start_pressed)
	back_button.pressed.connect(_on_back_pressed)

	_refresh_player_list()

func _load_settings_panel() -> void:
	for child in game_settings_container.get_children():
		child.queue_free()
	if current_manifest.settings_scene:
		settings_panel = current_manifest.settings_scene.instantiate()
		game_settings_container.add_child(settings_panel)

func _on_client_connected(_peer_id: int) -> void:
	pass

func _on_client_disconnected(peer_id: int) -> void:
	PlayerManager.remove_player(peer_id)
	_refresh_player_list()
	_broadcast_lobby_state()

func _on_message_received(sender_id: int, message: Dictionary) -> void:
	if message.get("type", "") == MessageTypes.PLAYER_HELLO:
		var player_name: String = message.get("name", "Player")
		PlayerManager.add_player(sender_id, player_name, false)
		var avatar_dict: Dictionary = message.get("avatar_data", {})
		if not avatar_dict.is_empty():
			var ad := AvatarData.new()
			ad.from_dict(avatar_dict)
			PlayerManager.get_player(sender_id).avatar_data = ad
		_refresh_player_list()
		_broadcast_lobby_state()

func _refresh_player_list() -> void:
	for child in player_list_container.get_children():
		child.queue_free()

	var players := PlayerManager.get_all_players()
	for p in players:
		var row := Label.new()
		var host_tag := " (Host)" if p.is_host else ""
		row.text = "• %s%s" % [p.display_name, host_tag]
		player_list_container.add_child(row)

	player_count_label.text = "Players: %d/%d" % [players.size(), current_manifest.max_players]
	start_button.disabled = false
	#start_button.disabled = players.size() < max(MIN_PLAYERS, current_manifest.min_players)
	print("fix start button on hostlobby.gd refresh_player_list")

func _broadcast_lobby_state() -> void:
	var names := []
	for p in PlayerManager.get_all_players():
		names.append(p.display_name)
	NetworkManager.broadcast_to_all({
		"type": MessageTypes.LOBBY_STATE,
		"player_names": names,
		"game_id": current_manifest.id,
	})

func _on_start_pressed() -> void:
	#if PlayerManager.get_all_players().size() < max(MIN_PLAYERS, current_manifest.min_players):
		#return
	print("same here")

	var settings := {}
	if settings_panel and settings_panel.has_method("get_settings"):
		settings = settings_panel.get_settings()

	NetworkManager.broadcast_to_all({
		"type": MessageTypes.GAME_START,
		"game_id": current_manifest.id,
		"settings": settings,
	})

	GameManager.start_match(current_manifest.id, PlayerManager.get_all_players(), settings)
	SceneManager.change_screen_to_packed(current_manifest.main_scene)

func _on_back_pressed() -> void:
	NetworkManager.close()
	SceneManager.change_screen_to_packed(Screens.GAME_SELECT)
