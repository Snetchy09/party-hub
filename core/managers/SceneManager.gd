extends Node

var _container: Control
var _current_screen: BaseScreen

# Your existing dictionary mapping the string keys to the actual files
const SCREEN_PATHS := {
	Screens.MAIN_MENU: "res://scenes/main_menu/MainMenu.tscn",
	Screens.GAME_SELECT: "res://scenes/game_select/GameSelectScreen.tscn",
	Screens.HOST_LOBBY: "res://scenes/lobby/HostLobby.tscn",
	Screens.JOIN_LOBBY: "res://scenes/lobby/JoinLobby.tscn",
	Screens.SETTINGS: "res://scenes/settings/SettingsScreen.tscn",
	Screens.WEREWOLVES_GAME: "res://games/werewolves/ui/GameScreen.tscn",
}

func initialize(container: Control) -> void:
	_container = container

# 1. Update the argument name and type to expect the screen identity key
# Change the argument type to Variant so it accepts Strings OR PackedScenes
func change_screen_to_packed(scene_input: Variant) -> void:
	if _container == null:
		push_error("SceneManager has not been initialized.")
		return
		
	var scene: PackedScene = null
	
	# Case A: A PackedScene object was passed directly (like from your Manifest)
	if scene_input is PackedScene:
		scene = scene_input
		
	# Case B: A String key was passed (like Screens.MAIN_MENU or Screens.GAME_SELECT)
	elif scene_input is String:
		# First, check if it's one of your pre-defined keys
		if SCREEN_PATHS.has(scene_input):
			scene = load(SCREEN_PATHS[scene_input]) as PackedScene
		else:
			# Otherwise, assume it's a direct resource path and try loading it
			scene = load(scene_input) as PackedScene
			
	# Safety check if neither case worked
	if scene == null:
		push_error("SceneManager: Invalid scene input or failed to load resource.")
		return

	# --- The rest of your function remains completely unchanged ---
	if _current_screen:
		_current_screen.exit()
		_current_screen.queue_free()

	_current_screen = scene.instantiate() as BaseScreen
	if _current_screen == null:
		push_error("Scene doesn't inherit BaseScreen.")
		return

	_container.add_child(_current_screen)
	_current_screen.enter()
