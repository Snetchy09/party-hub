extends PanelContainer

class_name PlayerCard

@onready var avatar_rect = $VBoxContainer/Avatar
@onready var name_label = $VBoxContainer/NameLabel
@onready var role_label = $VBoxContainer/RoleLabel
@onready var status_container = $VBoxContainer/StatusContainer

var player_id: int
var is_alive: bool = true

func _ready() -> void:
	custom_minimum_size = Vector2(120, 160)

func update_from_state(card_data: Dictionary) -> void:
	player_id = card_data["player_id"]
	is_alive = card_data["alive"]
	
	name_label.text = card_data["name"]
	
	# Show role only if revealed
	if card_data["role_revealed"]:
		role_label.text = card_data["role"].to_upper()
		role_label.show()
	else:
		role_label.hide()
	
	# Dead indicator
	if not is_alive:
		modulate = Color.GRAY
		name_label.text += " ✗"
	else:
		modulate = Color.WHITE
	
	# Status icons
	for child in status_container.get_children():
		child.queue_free()

	for status_key in card_data["statuses"]:
		if card_data["statuses"][status_key]:
			var icon = Label.new()
			match status_key:
				"protected":
					icon.text = "🛡️"
				"jailed":
					icon.text = "🔒"
				"voted":
					icon.text = "📍"
				_:
					icon.text = "⚪"
			status_container.add_child(icon)
