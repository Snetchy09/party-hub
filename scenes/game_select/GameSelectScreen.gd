extends BaseScreen

@onready var game_list_container: VBoxContainer = $MarginContainer/VBox/ScrollContainer/GameListContainer
@onready var back_button: Button = $MarginContainer/VBox/BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back)
	_populate_games()

func _populate_games() -> void:
	for child in game_list_container.get_children():
		child.queue_free()

	var games := GameRegistry.get_all_games()
	if games.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No games found. Check GameLoader paths."
		game_list_container.add_child(empty_label)
		return

	for manifest in games:
		var entry := _build_game_entry(manifest)
		game_list_container.add_child(entry)

func _build_game_entry(manifest: GameManifest) -> Control:
	var panel := PanelContainer.new()
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	panel.add_child(hbox)

	if manifest.icon:
		var icon_rect := TextureRect.new()
		icon_rect.texture = manifest.icon
		icon_rect.custom_minimum_size = Vector2(64, 64)
		icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		hbox.add_child(icon_rect)

	var text_vbox := VBoxContainer.new()
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var title := Label.new()
	title.text = manifest.display_name
	title.add_theme_font_size_override("font_size", 20)
	text_vbox.add_child(title)

	var desc := Label.new()
	desc.text = manifest.description
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	text_vbox.add_child(desc)

	var players_label := Label.new()
	players_label.text = "%d–%d players" % [manifest.min_players, manifest.max_players]
	text_vbox.add_child(players_label)

	hbox.add_child(text_vbox)

	var select_button := Button.new()
	select_button.text = "Select"
	select_button.pressed.connect(func(): _on_game_selected(manifest))
	hbox.add_child(select_button)

	return panel

func _on_game_selected(manifest: GameManifest) -> void:
	PlayerManager.selected_game_id = manifest.id
	SceneManager.change_screen_to_packed(Screens.HOST_LOBBY)

func _on_back() -> void:
	SceneManager.change_screen_to_packed(Screens.MAIN_MENU)
