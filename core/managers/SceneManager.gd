extends Node

var _container: Control
var _current_screen: BaseScreen


func initialize(container: Control) -> void:
	_container = container


func change_screen(screen_scene: PackedScene) -> void:
	if _container == null:
		push_error("SceneManager has not been initialized.")
		return

	if _current_screen:
		_current_screen.exit()
		_current_screen.queue_free()

	_current_screen = screen_scene.instantiate() as BaseScreen

	if _current_screen == null:
		push_error("Screen does not inherit from BaseScreen.")
		return

	_container.add_child(_current_screen)

	_current_screen.enter()
