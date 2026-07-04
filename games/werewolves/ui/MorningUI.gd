extends Control

@onready var events_container: VBoxContainer = $MarginContainer/VBox/EventsContainer
@onready var player_grid: PlayerGridUI = $MarginContainer/VBox/PlayerGrid

func initialize(state: Dictionary, my_player_id: int) -> void:
	update_state(state)

func update_state(state: Dictionary) -> void:
	player_grid.update_from_state(state.get("cards", []))
	player_grid.set_cards_selectable(false)

## Called by GameScreen when phase_change message includes "events"
func show_night_events(events: Array) -> void:
	for child in events_container.get_children():
		child.queue_free()

	if events.is_empty():
		_add_event_line("A quiet night. No one died.")
		return

	for event in events:
		var text := _format_event(event)
		if text != "":
			_add_event_line(text)

func _format_event(event: Dictionary) -> String:
	match event.get("type", ""):
		"death":
			match event.get("cause", ""):
				"night_kill":
					return "💀 A player was found dead this morning."
				"voted_out":
					return ""  # not relevant for morning, this is a day event
				"jailer":
					return "🔒 A prisoner was silenced overnight."
				"hacker":
					return "⚡ Something strange happened... a player vanished."
				"sacrifice":
					return "🩸 A villager was sacrificed."
				"reflected":
					return "🪞 Darkness turned back upon its source."
		"reveal":
			return "👁️ A hidden role has been revealed!"
		"kill_blocked":
			return "🛡️ An attack was thwarted by protection."
	return ""

func _add_event_line(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	events_container.add_child(label)
