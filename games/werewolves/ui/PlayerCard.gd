extends PanelContainer
class_name PlayerCard

signal card_clicked(player_id: int)

@onready var avatar: AvatarDisplay = $MarginContainer/VBox/AvatarWrapper/Avatar
@onready var name_label: Label = $MarginContainer/VBox/NameLabel
@onready var role_label: Label = $MarginContainer/VBox/RoleLabel
@onready var status_row: HBoxContainer = $MarginContainer/VBox/StatusRow
@onready var dead_overlay: ColorRect = $MarginContainer/VBox/DeadOverlay

var player_id: int = -1

const STATUS_ICONS := {
	"jailed": "🔒",
	"blessed": "✨",
	"protected": "🛡️",
}

func _ready() -> void:
	gui_input.connect(_on_gui_input)

func update_from_state(data: Dictionary) -> void:
	player_id = data.get("player_id", -1)
	name_label.text = data.get("name", "?")

	var avatar_dict: Dictionary = data.get("avatar_data", {})
	if not avatar_dict.is_empty():
		var avatar_data := AvatarData.new()
		avatar_data.from_dict(avatar_dict)
		avatar.apply_avatar(avatar_data)

	if data.get("role_revealed", false) and data.get("role_display", "") != "":
		role_label.text = data["role_display"]
		role_label.show()
	else:
		role_label.hide()

	var alive: bool = data.get("alive", true)
	if dead_overlay:
		dead_overlay.visible = not alive
	modulate = Color(1, 1, 1, 1) if alive else Color(0.5, 0.5, 0.5, 0.85)

	for child in status_row.get_children():
		child.queue_free()
	for status in data.get("statuses", []):
		var badge := Label.new()
		badge.text = STATUS_ICONS.get(status, "")
		badge.add_theme_font_size_override("font_size", 16)
		status_row.add_child(badge)

func set_selectable(selectable: bool) -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP if selectable else Control.MOUSE_FILTER_IGNORE

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_clicked.emit(player_id)
