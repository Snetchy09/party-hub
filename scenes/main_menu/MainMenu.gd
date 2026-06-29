extends BaseScreen


@onready var create_room_button: Button = %CreateRoomButton
@onready var join_room_button: Button = %JoinRoomButton
@onready var settings_button: Button = %SettingsButton


func _ready() -> void:
	create_room_button.pressed.connect(_on_create_room_pressed)
	join_room_button.pressed.connect(_on_join_room_pressed)
	settings_button.pressed.connect(_on_settings_pressed)


func _on_create_room_pressed() -> void:
	print("Create Room")


func _on_join_room_pressed() -> void:
	print("Join Room")


func _on_settings_pressed() -> void:
	print("Settings")
