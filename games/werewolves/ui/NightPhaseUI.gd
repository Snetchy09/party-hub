extends Control

@onready var role_reminder: Label = $VBox/RoleReminderLabel
@onready var instruction_label: Label = $VBox/InstructionLabel
@onready var timer_label: Label = $VBox/TimerLabel
@onready var player_grid: PlayerGridUI = $VBox/PlayerGrid
@onready var sleeping_label: Label = $VBox/SleepingLabel
@onready var secret_chat: SecretChatUI = $VBox/SecretChatPanel

var my_role_id: String = ""
var can_act: bool = false
var action_type: String = ""
var has_submitted: bool = false

const ACTION_BY_ROLE := {
	"werewolf": "kill",
	"doctor": "protect",
	"aura_seer": "investigate",
	"witch": "witch_bless",  # actual sub-type chosen via toggle, see below
	"jailer": "jail_chat",
	"mirror": "reflect",
	"medium": "revive",
	"streets_lady": "visit",
	"bloody_seer": "sacrifice",
	"hacker": "hack_use",
}

const INSTRUCTION_BY_ROLE := {
	"werewolf": "Choose who to slaughter:",
	"doctor": "Choose who to protect:",
	"aura_seer": "Choose who to investigate:",
	"witch": "Choose your target:",
	"jailer": "Speak with your prisoner, or end the night:",
	"mirror": "Choose who to reflect:",
	"medium": "Choose a fallen soul to revive (optional):",
	"streets_lady": "Choose who to visit:",
	"bloody_seer": "Choose a villager to sacrifice:",
	"hacker": "Use your hacked target's power on:",
}

func initialize(state: Dictionary, my_player_id: int) -> void:
	update_state(state)
	player_grid.card_selected.connect(_on_player_selected)

func update_state(state: Dictionary) -> void:
	my_role_id = state.get("my_role", "")
	can_act = state.get("my_can_act_night", false) and state.get("can_use_ability", false)
	action_type = ACTION_BY_ROLE.get(my_role_id, "")

	role_reminder.text = "Your Role: %s" % state.get("my_role_display", "")
	timer_label.text = "⏱ %ds" % int(state.get("timer", 0))

	player_grid.update_from_state(state.get("cards", []))

	var chat_type: String = state.get("secret_chat_type", "none")
	secret_chat.visible = chat_type in ["jailer", "jailed"]
	if secret_chat.visible:
		secret_chat.setup(state.get("my_player_id", -1))

	if not can_act or has_submitted:
		sleeping_label.show()
		instruction_label.hide()
		player_grid.set_cards_selectable(false)
		if not can_act:
			sleeping_label.text = "🌙 The village sleeps..."
		else:
			sleeping_label.text = "✓ Action submitted. Waiting for others..."
	else:
		sleeping_label.hide()
		instruction_label.show()
		instruction_label.text = INSTRUCTION_BY_ROLE.get(my_role_id, "Choose a target:")
		player_grid.set_cards_selectable(true)

	if my_role_id == "witch":
		var witch_type: String = state.get("my_witch_type", "")
		action_type = "witch_bless" if witch_type == "white" else "witch_curse"

func _on_player_selected(player_id: int) -> void:
	if has_submitted or not can_act:
		return
	has_submitted = true
	NetworkManager.send_to_host({
		"type": "night_action",
		"action_type": action_type,
		"target_id": player_id,
	})
	sleeping_label.text = "✓ Action submitted. Waiting for others..."
	sleeping_label.show()
	instruction_label.hide()
	player_grid.set_cards_selectable(false)

func receive_chat_message(message: Dictionary) -> void:
	if message.get("chat", "") == "jailer":
		secret_chat.receive_message(message["message"])
