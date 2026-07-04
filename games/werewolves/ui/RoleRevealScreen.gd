extends Control

signal reveal_complete

@onready var card_panel: PanelContainer = $CenterContainer/CardPanel
@onready var avatar: AvatarDisplay = $CenterContainer/CardPanel/MarginContainer/VBox/AvatarWrapper/Avatar
@onready var name_label: Label = $CenterContainer/CardPanel/MarginContainer/VBox/NameLabel
@onready var role_label: Label = $CenterContainer/CardPanel/MarginContainer/VBox/RoleLabel
@onready var desc_label: Label = $CenterContainer/CardPanel/MarginContainer/VBox/DescLabel

var is_revealed: bool = false
var my_role_id: String = ""
var my_role_display: String = ""
var my_role_description: String = ""
var my_team: String = ""
var _has_been_initialized: bool = false

const TEAM_GLOW := {
	"village": Color(0.4, 0.95, 0.5),
	"werewolves": Color(0.95, 0.2, 0.2),
	"village_or_werewolves": Color(0.95, 0.2, 0.2),
	"solo": Color(0.75, 0.3, 0.95),
}

func _ready() -> void:
	card_panel.gui_input.connect(_on_card_input)
	role_label.text = "◈  TAP TO REVEAL  ◈"
	role_label.modulate = Color(1, 0.85, 0.2)
	desc_label.hide()
	await get_tree().process_frame
	card_panel.pivot_offset = card_panel.size / 2.0

func initialize(state: Dictionary, my_player_id: int) -> void:
	if _has_been_initialized:
		return
	_has_been_initialized = true
	print("RoleReveal initialize called for player", my_player_id, "state keys:", state.keys())
	my_role_id = state.get("my_role", "")
	my_role_display = state.get("my_role_display", "")
	my_role_description = state.get("my_role_description", "")
	my_team = state.get("my_team", "")
	print("my_role_display=", my_role_display, "my_team=", my_team)
	for c in state.get("cards", []):
		if c["player_id"] == my_player_id:
			name_label.text = c.get("name", "You")
			var avatar_dict: Dictionary = c.get("avatar_data", {})
			if not avatar_dict.is_empty():
				var ad := AvatarData.new()
				ad.from_dict(avatar_dict)
				avatar.apply_avatar(ad)
			break

func _on_card_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not is_revealed:
			_reveal()
		else:
			_hide_and_complete()

func _reveal() -> void:
	print("_reveal() called; my_role_display=", my_role_display, "my_role_id=", my_role_id)
	is_revealed = true
	var tween := create_tween()
	tween.tween_property(card_panel, "scale:x", 0.0, 0.15)
	await tween.finished
	var glow: Color = TEAM_GLOW.get(my_team, Color.WHITE)
	role_label.text = "◈  %s  ◈" % my_role_display.to_upper()
	role_label.modulate = glow
	desc_label.text = my_role_description
	desc_label.show()
	tween = create_tween()
	tween.tween_property(card_panel, "scale:x", 1.0, 0.15)

func _hide_and_complete() -> void:
	is_revealed = false
	var tween := create_tween()
	tween.tween_property(card_panel, "scale", Vector2(0.3, 0.3), 0.4)
	tween.parallel().tween_property(card_panel, "modulate:a", 0.0, 0.4)
	await tween.finished
	print("hide start")
	await get_tree().process_frame
	print("hide after frame")
	reveal_complete.emit()
	NetworkManager.send_to_host({"type": "reveal_done"})
	_check_special_modal()

func _check_special_modal() -> void:
	match my_role_id:
		"witch":
			var modal = load("res://games/werewolves/ui/WitchChoiceModal.tscn").instantiate()
			get_tree().current_scene.add_child(modal)
		"investigator":
			var modal = load("res://games/werewolves/ui/InvestigatorSetupModal.tscn").instantiate()
			get_tree().current_scene.add_child(modal)
