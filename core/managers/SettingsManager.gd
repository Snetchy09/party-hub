extends Node

var player_name: String = "Player"
var language: String = "en"
var sound_enabled: bool = true
var music_enabled: bool = true
var avatar_data: AvatarData = AvatarData.new()  # ← this is what was missing

const SAVE_PATH := "user://settings.json"

func _ready() -> void:
	load_settings()

func save_settings() -> void:
	var data := {
		"player_name": player_name,
		"language": language,
		"sound_enabled": sound_enabled,
		"music_enabled": music_enabled,
		"avatar_data": avatar_data.to_dict(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_settings() -> void:
	avatar_data = AvatarData.new()
	if not FileAccess.file_exists(SAVE_PATH):
		player_name = "Player%d" % (randi() % 1000)
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var text := file.get_as_text()
	file.close()
	var json := JSON.new()
	if json.parse(text) != OK:
		return
	var d: Dictionary = json.data
	player_name = d.get("player_name", "Player")
	language = d.get("language", "en")
	sound_enabled = d.get("sound_enabled", true)
	music_enabled = d.get("music_enabled", true)
	if d.has("avatar_data"):
		avatar_data.from_dict(d["avatar_data"])
