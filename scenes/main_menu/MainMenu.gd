extends BaseScreen

@onready var create_button: Button = $SafeArea/VBoxContainer/Buttons/CreateRoomButton
@onready var join_button: Button = $SafeArea/VBoxContainer/Buttons/JoinRoomButton
@onready var settings_button: Button = $SafeArea/VBoxContainer/Buttons/SettingsButton
@onready var edit_avatar_button: Button = $SafeArea/VBoxContainer/Buttons/EditAvatarButton

func _ready() -> void:
	create_button.pressed.connect(_on_create_pressed)
	join_button.pressed.connect(_on_join_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	edit_avatar_button.pressed.connect(_on_edit_avatar_pressed)

func _on_create_pressed() -> void:
	SceneManager.change_screen(Screens.HOST_LOBBY)

func _on_join_pressed() -> void:
	SceneManager.change_screen(Screens.JOIN_LOBBY)

func _on_settings_pressed() -> void:
	SceneManager.change_screen(Screens.SETTINGS)

func _on_edit_avatar_pressed() -> void:
	var customizer = load("res://core/ui/avatar/AvatarCustomizer.tscn").instantiate()
	$PopupLayer.add_child(customizer)  # adds to CanvasLayer, renders on top of everything
	customizer.customization_done.connect(func(avatar_data: AvatarData):
		SettingsManager.avatar_data = avatar_data
		SettingsManager.save_settings()
		customizer.queue_free()
	)
