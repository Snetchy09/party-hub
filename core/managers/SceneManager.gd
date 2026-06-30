extends Node

var _container: Control
var _current_screen: BaseScreen

const SCREEN_PATHS := {
	Screens.MAIN_MENU: "res://scenes/main_menu/MainMenu.tscn",
	Screens.HOST_LOBBY: "res://scenes/lobby/HostLobby.tscn",
	Screens.JOIN_LOBBY: "res://scenes/lobby/JoinLobby.tscn",
	Screens.SETTINGS: "res://scenes/settings/SettingsScreen.tscn",
	Screens.WEREWOLVES_GAME: "res://games/werewolves/ui/GameScreen.tscn",
}

func initialize(container: Control) -> void:
	_container = container

func change_screen(screen: String) -> void:
	if _container == null:
		push_error("SceneManager has not been initialized.")
		return

	if !SCREEN_PATHS.has(screen):
		push_error("Unknown screen: %s" % screen)
		return

	var scene := load(SCREEN_PATHS[screen]) as PackedScene

	if scene == null:
		push_error("Couldn't load scene: %s" % SCREEN_PATHS[screen])
		return

	if _current_screen:
		_current_screen.exit()
		_current_screen.queue_free()

	_current_screen = scene.instantiate() as BaseScreen

	if _current_screen == null:
		push_error("Scene doesn't inherit BaseScreen.")
		return

	_container.add_child(_current_screen)
	_current_screen.enter()
