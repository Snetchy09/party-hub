extends BaseScreen

@onready var phase_label: Label = $PhaseLabel
@onready var content_container: Control = $ContentContainer
@onready var announcement_overlay: Control = $AnnouncementOverlay
@onready var night_overlay: ColorRect = $NightOverlay

var current_phase_ui: Control = null
var my_player_id: int = -1
var latest_state: Dictionary = {}

const PHASE_TEXT := {
	"night": ["🌙 NIGHT FALLS", "The village sleeps..."],
	"morning": ["🌅 DAWN BREAKS", "The night's deeds are revealed"],
	"discussion": ["☀️ DISCUSSION", "Deliberate. Decide."],
	"voting": ["⚖️ VOTE", "Cast your judgment"],
	"execution": ["💀 EXECUTION", "Justice is served"],
}

func _ready() -> void:
	my_player_id = NetworkManager.get_my_peer_id()
	NetworkManager.message_received.connect(_on_message)

	# Make announcement overlay ignore mouse input by default and ensure hidden
	announcement_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	announcement_overlay.hide()

	_show_role_reveal()

func _on_message(_sender_id: int, message: Dictionary) -> void:
	match message.get("type", ""):
		"state_update":
			print("GameScreen received", message.get("type"))
			latest_state = message["state"]
			_apply_state(latest_state)
			if latest_state.get("phase", "") == "role_reveal":
				if current_phase_ui and current_phase_ui.has_method("initialize"):
					current_phase_ui.initialize(latest_state, my_player_id)
		"phase_change":
			print("GameScreen received", message.get("type"))
			_transition_phase(message["phase"])
			if message["phase"] == "morning" and current_phase_ui and current_phase_ui.has_method("show_night_events"):
				current_phase_ui.show_night_events(message.get("events", []))
		"vote_counts":
			if current_phase_ui and current_phase_ui.has_method("update_vote_counts"):
				current_phase_ui.update_vote_counts(message["counts"])
		"secret_chat_message":
			if current_phase_ui and current_phase_ui.has_method("receive_chat_message"):
				current_phase_ui.receive_chat_message(message)
		"execution_result":
			if current_phase_ui and current_phase_ui.has_method("show_execution_result"):
				current_phase_ui.show_execution_result(message["result"])
		"game_end":
			_show_game_end(message)

func _apply_state(state: Dictionary) -> void:
	if current_phase_ui and current_phase_ui.has_method("update_state"):
		current_phase_ui.update_state(state)

	var is_night: bool = state.get("phase", "") == "night"
	var target_alpha := 0.45 if is_night else 0.0
	var tween := create_tween()
	tween.tween_property(night_overlay, "color:a", target_alpha, 1.0)

func _transition_phase(phase: String, events: Array = []) -> void:
	if phase in PHASE_TEXT:
		await _show_announcement(PHASE_TEXT[phase][0], PHASE_TEXT[phase][1])

	if current_phase_ui:
		current_phase_ui.queue_free()
		current_phase_ui = null

	match phase:
		"night":
			current_phase_ui = load("res://games/werewolves/ui/NightPhaseUI.tscn").instantiate()
		"morning":
			current_phase_ui = load("res://games/werewolves/ui/MorningUI.tscn").instantiate()
		"discussion", "voting":
			current_phase_ui = load("res://games/werewolves/ui/DayPhaseUI.tscn").instantiate()

	if current_phase_ui:
		content_container.add_child(current_phase_ui)
		if current_phase_ui.has_method("initialize"):
			current_phase_ui.initialize(latest_state, my_player_id)
		if phase == "morning" and current_phase_ui.has_method("show_night_events"):
			current_phase_ui.show_night_events(events)

func _show_role_reveal() -> void:
	current_phase_ui = load("res://games/werewolves/ui/RoleRevealScreen.tscn").instantiate()
	content_container.add_child(current_phase_ui)
	current_phase_ui.reveal_complete.connect(_on_reveal_complete)
	# Don't initialize yet — wait for state_update message which carries role info

func _on_reveal_complete() -> void:
	pass  # GameManager handles the actual "all players ready" tracking host-side

func _show_announcement(title: String, subtitle: String) -> void:
	announcement_overlay.show()
	announcement_overlay.modulate.a = 0.0
	for child in announcement_overlay.get_children():
		child.queue_free()
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	var title_label := Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 36)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var sub_label := Label.new()
	sub_label.text = subtitle
	sub_label.add_theme_font_size_override("font_size", 18)
	sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_label)
	vbox.add_child(sub_label)
	announcement_overlay.add_child(vbox)

	var tween := create_tween()
	tween.tween_property(announcement_overlay, "modulate:a", 1.0, 0.4)
	await get_tree().create_timer(2.2).timeout
	tween = create_tween()
	tween.tween_property(announcement_overlay, "modulate:a", 0.0, 0.4)
	await tween.finished
	announcement_overlay.hide()

func _show_game_end(message: Dictionary) -> void:
	if current_phase_ui:
		current_phase_ui.queue_free()
	var win_screen = load("res://games/werewolves/ui/WinScreen.tscn").instantiate()
	content_container.add_child(win_screen)
	win_screen.initialize(message)
