extends Control

@onready var current_scene_container: Control = $CurrentScene

func _ready() -> void:
	SceneManager.initialize(current_scene_container)
	SceneManager.change_screen_to_packed.call_deferred(Screens.MAIN_MENU)
