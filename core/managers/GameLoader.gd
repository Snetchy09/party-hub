extends Node

const GAMES_FOLDER := "res://games/"


func _ready() -> void:
	load_games()


func load_games() -> void:
	var dir := DirAccess.open(GAMES_FOLDER)

	if dir == null:
		push_error("Cannot open games folder.")
		return

	dir.list_dir_begin()

	while true:
		var folder := dir.get_next()

		if folder == "":
			break

		if folder.begins_with("."):
			continue

		if dir.current_is_dir():
			load_game(folder)

	dir.list_dir_end()


func load_game(game_folder: String) -> void:
	var path := "%s%s/resources/" % [GAMES_FOLDER, game_folder]

	if !DirAccess.dir_exists_absolute(path):
		return

	var files := DirAccess.get_files_at(path)

	for file in files:
		if file.ends_with(".tres"):
			var manifest = load(path + file)

			if manifest is GameManifest:
				GameRegistry.register_game(manifest)
