# games/werewolves/ui/PlayerCard.tscn (scene)
# Structure:
# Control (PlayerCard.gd)
#   ├── TextureRect (avatar)
#   ├── Label (name)
#   ├── Label (role - initially hidden)
#   ├── HBoxContainer (status icons)
#   └── ColorRect (dead overlay - grayed out)

# games/werewolves/ui/PlayerCard.gd
extends Control

class_name PlayerCard

@onready var avatar = $Avatar
@onready var name_label = $NameLabel
@onready var role_label = $RoleLabel
@onready var status_container = $StatusContainer
@onready var dead_overlay = $DeadOverlay

func update_data(card_data: Dictionary) -> void:
	name_label.text = card_data["name"]
	avatar.texture = load("res://assets/avatars/%s.png" % card_data["name"].to_lower())
	
	# Update role (only show if revealed)
	if card_data["role_revealed"]:
		role_label.text = card_data["role"].to_upper()
		role_label.show()
	else:
		role_label.hide()
	
	# Update status indicators
	status_container.clear()
	for status_key in card_data["statuses"]:
		if card_data["statuses"][status_key]:
			var icon = create_status_icon(status_key)
			status_container.add_child(icon)
	
	# Update alive state
	if not card_data["alive"]:
		dead_overlay.show()
		name_label.text += " (DEAD)"
	else:
		dead_overlay.hide()

func create_status_icon(status: String) -> TextureRect:
	var icon = TextureRect.new()
	icon.texture = load("res://assets/status_icons/%s.png" % status)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.custom_minimum_size = Vector2(20, 20)
	return icon
