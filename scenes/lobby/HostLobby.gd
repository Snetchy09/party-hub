extends BaseScreen

@onready var ip_label: Label = $MarginContainer/VBoxContainer/IPPanel/IPLabel
@onready var player_count_label: Label = $MarginContainer/VBoxContainer/PlayerCountLabel
@onready var player_list_container: VBoxContainer = $MarginContainer/VBoxContainer/PlayerListContainer
@onready var mode_option: OptionButton = $MarginContainer/VBoxContainer/ModeOptionButton
@onready var start_button: Button = $MarginContainer/VBoxContainer/StartButton
@onready var back_button: Button = $MarginContainer/VBoxContainer/BackButton

const MIN_PLAYERS := 4

func _ready() -> void:
	var err := NetworkManager.create_server()
	if err != OK:
		ip_label.text = "Failed to host. Check network settings."
		return

	ip_label.text = "IP: %s   Port: %s" % [NetworkManager.get_local_ip_guess(), NetworkManager.PORT]

	NetworkManager.client_connected.connect(_on_client_connected)
	NetworkManager.client_disconnected.connect(_on_client_disconnected)
	NetworkManager.message_received.connect(_on_message_received)

	PlayerManager.reset()
	PlayerManager.add_player(1, SettingsManager.player_name, true)  # host is always peer 1

	start_button.pressed.connect(_on_start_pressed)
	back_button.pressed.connect(_on_back_pressed)

	_refresh_player_list()

func _on_client_connected(peer_id: int) -> void:
	# Wait for the client to send player_hello with their name before adding them
	pass

func _on_client_disconnected(peer_id: int) -> void:
	PlayerManager.remove_player(peer_id)
	_refresh_player_list()
	_broadcast_lobby_state()

func _on_message_received(sender_id: int, message: Dictionary) -> void:
	if message.get("type", "") == MessageTypes.PLAYER_HELLO:
		var player_name: String = message.get("name", "Player")
		PlayerManager.add_player(sender_id, player_name, false)
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

	player_count_label.text = "Players: %d/20" % players.size()
	start_button.disabled = players.size() < MIN_PLAYERS

func _broadcast_lobby_state() -> void:
	var names := []
	for p in PlayerManager.get_all_players():
		names.append(p.display_name)
	NetworkManager.broadcast_to_all({
		"type": MessageTypes.LOBBY_STATE,
		"player_names": names,
	})

func _on_start_pressed() -> void:
	if PlayerManager.get_all_players().size() < MIN_PLAYERS:
		return
	var settings := {
		"role_pack": mode_option.get_item_text(mode_option.selected),
	}
	NetworkManager.broadcast_to_all({
		"type": MessageTypes.GAME_START,
		"settings": settings,
	})
	GameManager.start_werewolves_match(PlayerManager.get_all_players(), settings)
	SceneManager.change_screen(Screens.WEREWOLVES_GAME)

func _on_back_pressed() -> void:
	NetworkManager.close()
	SceneManager.change_screen(Screens.MAIN_MENU)
