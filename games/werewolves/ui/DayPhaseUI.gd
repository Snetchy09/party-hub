extends Control

@onready var phase_title: Label = $MarginContainer/VBox/PhaseTitleLabel
@onready var timer_label: Label = $MarginContainer/VBox/TimerLabel
@onready var player_grid: PlayerGridUI = $MarginContainer/VBox/PlayerGrid
@onready var vote_count_label: Label = $MarginContainer/VBox/VoteCountLabel
@onready var special_actions_row: HBoxContainer = $MarginContainer/VBox/SpecialActionsRow

var current_phase: String = ""
var my_role_id: String = ""
var has_voted: bool = false

func initialize(state: Dictionary, _my_player_id: int) -> void:
	update_state(state)
	player_grid.card_selected.connect(_on_card_selected)

func update_state(state: Dictionary) -> void:
	current_phase = state.get("phase", "discussion")
	my_role_id = state.get("my_role", "")
	timer_label.text = "⏱ %ds" % int(state.get("timer", 0))
	player_grid.update_from_state(state.get("cards", []))

	if current_phase == "discussion":
		phase_title.text = "☀️ Discuss"
		vote_count_label.hide()
		player_grid.set_cards_selectable(false)
		_build_judge_buttons(state)
	elif current_phase == "voting":
		phase_title.text = "⚖️ Vote"
		vote_count_label.show()
		var alive: bool = state.get("my_alive", true)
		player_grid.set_cards_selectable(alive and not has_voted)
		for child in special_actions_row.get_children():
			child.queue_free()

func update_vote_counts(counts: Dictionary) -> void:
	var lines := []
	for pid in counts:
		lines.append("Player %s: %s votes" % [pid, counts[pid]])
	vote_count_label.text = "\n".join(lines)

func show_execution_result(result: Dictionary) -> void:
	if result.get("executed_id", -1) == -1:
		vote_count_label.text = "No one was executed (tie or no votes)."
	else:
		vote_count_label.text = "Player %s was executed." % result["executed_id"]

func _on_card_selected(player_id: int) -> void:
	if current_phase != "voting" or has_voted:
		return
	has_voted = true
	NetworkManager.send_to_host({"type": "vote", "target_id": player_id})
	player_grid.set_cards_selectable(false)

func _build_judge_buttons(state: Dictionary) -> void:
	for child in special_actions_row.get_children():
		child.queue_free()
	if my_role_id != "judge":
		return

	var private_info: Dictionary = state.get("private_info", {})

	if not private_info.get("skip_used", true):
		var skip_btn := Button.new()
		skip_btn.text = "Skip to Night"
		skip_btn.pressed.connect(func(): NetworkManager.send_to_host({"type": "judge_skip"}))
		special_actions_row.add_child(skip_btn)

	if not private_info.get("free_used", true):
		var free_btn := Button.new()
		free_btn.text = "Free Prisoner"
		free_btn.pressed.connect(func(): NetworkManager.send_to_host({"type": "judge_free"}))
		special_actions_row.add_child(free_btn)
