extends BaseScreen

@onready var ip_input: LineEdit = $MarginContainer/VBoxContainer/IPInput
@onready var connect_button: Button = $MarginContainer/VBoxContainer/ConnectButton
@onready var status_label: Label = $MarginContainer/VBoxContainer/StatusLabel
@onready var waiting_label: Label = $MarginContainer/VBoxContainer/WaitingLabel
@onready var player_list_container: VBoxContainer = $MarginContainer/VBoxContainer/PlayerListContainer
@onready var back_button: Button = $MarginContainer/VBoxContainer/BackButton

func _ready() -> void:
	connect_button.pressed.connect(_on_connect_pressed)
	back_button.pressed.connect(_on_back_pressed)
	NetworkManager.message_received.connect(_on_message_received)

func _on_connect_pressed() -> void:
	var ip := ip_input.text.strip_edges()
	if ip.is_empty():
		status_label.text = "Please enter an IP address."
		return

	status_label.text = "Connecting..."
	connect_button.disabled = true

	var err := NetworkManager.join_server(ip)
	if err != OK:
		status_label.text = "Could not connect."
		connect_button.disabled = false
		return

	NetworkManager.connection_succeeded.connect(_on_connected, CONNECT_ONE_SHOT)
	NetworkManager.connection_failed.connect(_on_failed, CONNECT_ONE_SHOT)

func _on_connected() -> void:
	status_label.text = "Connected! Waiting for host to start..."
	waiting_label.text = "You're in the lobby."
	NetworkManager.send_to_host({
		"type": MessageTypes.PLAYER_HELLO,
		"name": SettingsManager.player_name,
		"avatar_data": SettingsManager.avatar_data.to_dict(),
	})

func _on_failed() -> void:
	status_label.text = "Connection failed. Check the IP and try again."
	connect_button.disabled = false

func _on_message_received(_sender_id: int, message: Dictionary) -> void:
	match message.get("type", ""):
		MessageTypes.LOBBY_STATE:
			_refresh_player_list(message.get("player_names", []))
		MessageTypes.GAME_START:
			PlayerManager.local_settings = message.get("settings", {})
			SceneManager.change_screen(Screens.WEREWOLVES_GAME)

func _refresh_player_list(names: Array) -> void:
	for child in player_list_container.get_children():
		child.queue_free()
	for n in names:
		var row := Label.new()
		row.text = "• %s" % n
		player_list_container.add_child(row)

func _on_back_pressed() -> void:
	NetworkManager.close()
	SceneManager.change_screen(Screens.MAIN_MENU)
