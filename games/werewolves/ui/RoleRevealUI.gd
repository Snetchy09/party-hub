extends Control

class_name RoleRevealUI

var card_container: Control
var waiting_label: Label

var my_role: RoleData
var my_player_id: int
var is_revealed: bool = false
var can_interact: bool = true

signal reveal_complete

func _ready() -> void:
	create_ui()

func create_ui() -> void:
	var vbox = VBoxContainer.new()
	add_child(vbox)
	
	waiting_label = Label.new()
	waiting_label.text = "Waiting for your role..."
	waiting_label.add_theme_font_size_override("font_size", 20)
	waiting_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(waiting_label)
	
	card_container = Control.new()
	card_container.custom_minimum_size = Vector2(400, 600)
	vbox.add_child(card_container)

func set_my_role(role: RoleData, player_id: int) -> void:
	my_role = role
	my_player_id = player_id
	
	# Hide waiting label instead of freeing it
	if waiting_label:
		waiting_label.hide()
	
	create_card()

func create_card() -> void:
	var card_panel = PanelContainer.new()
	card_panel.custom_minimum_size = Vector2(400, 600)
	card_panel.modulate = Color.WHITE
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	
	# Avatar placeholder
	var avatar_rect = ColorRect.new()
	avatar_rect.color = Color.GRAY
	avatar_rect.custom_minimum_size = Vector2(300, 300)
	vbox.add_child(avatar_rect)
	
	# Name
	var name_label = Label.new()
	name_label.text = "Your Role"
	name_label.add_theme_font_size_override("font_size", 28)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)
	
	# Role (hidden until tap)
	var role_label = Label.new()
	role_label.text = "TAP TO REVEAL"
	role_label.add_theme_font_size_override("font_size", 24)
	role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	role_label.modulate = Color.YELLOW
	role_label.name = "RoleLabel"
	vbox.add_child(role_label)
	
	card_panel.add_child(vbox)
	card_container.add_child(card_panel)
	
	card_panel.gui_input.connect(_on_card_input)

func _on_card_input(event: InputEvent) -> void:
	if not can_interact:
		return
	
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		if not is_revealed:
			flip_to_reveal()
		else:
			flip_to_hidden_and_shrink()

func flip_to_reveal() -> void:
	is_revealed = true
	can_interact = false
	
	var card_panel = card_container.get_child(0) as PanelContainer
	var vbox = card_panel.get_child(0) as VBoxContainer
	var role_label = vbox.get_node("RoleLabel") as Label
	
	# Animate flip
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(card_panel, "scale", Vector2(1.05, 1.05), 0.3)
	
	await tween.finished
	
	# Show role
	role_label.text = my_role.display_name.to_upper()
	role_label.modulate = Color.LIGHT_GREEN
	
	# Wait 2 seconds then auto-shrink
	await get_tree().create_timer(2.0).timeout
	flip_to_hidden_and_shrink()

func flip_to_hidden_and_shrink() -> void:
	var card_panel = card_container.get_child(0) as PanelContainer
	var vbox = card_panel.get_child(0) as VBoxContainer
	var role_label = vbox.get_node("RoleLabel") as Label
	
	# Reset label
	role_label.text = "TAP TO REVEAL"
	role_label.modulate = Color.YELLOW
	
	# Animate shrink
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(card_panel, "scale", Vector2(0.3, 0.3), 0.5)
	tween.tween_property(card_panel, "modulate", Color.WHITE.darkened(0.3), 0.5)
	
	await tween.finished
	
	is_revealed = false
	reveal_complete.emit()
