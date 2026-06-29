extends Control

@onready var current_scene: Control = $CurrentScene


func _ready() -> void:
	SceneManager.initialize(current_scene)
