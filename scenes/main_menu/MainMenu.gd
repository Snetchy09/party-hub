extends BaseScreen

@onready var create_button: Button = $UILayer/SafeArea/VBoxContainer/Buttons/CreateRoomButton
@onready var join_button: Button = $UILayer/SafeArea/VBoxContainer/Buttons/JoinRoomButton
@onready var settings_button: Button = $UILayer/SafeArea/VBoxContainer/Buttons/SettingsButton

func _ready() -> void:
	create_button.pressed.connect(_on_create_pressed)
	join_button.pressed.connect(_on_join_pressed)
	settings_button.pressed.connect(_on_settings_pressed)

func _on_create_pressed() -> void:
	SceneManager.change_screen(Screens.HOST_LOBBY)

func _on_join_pressed() -> void:
	SceneManager.change_screen(Screens.JOIN_LOBBY)

func _on_settings_pressed() -> void:
	SceneManager.change_screen(Screens.SETTINGS)
