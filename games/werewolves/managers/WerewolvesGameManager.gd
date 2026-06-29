class_name WerewolvesGameManager
extends Node

var role_manager: RoleManager
var role_generator := RoleGenerator.new()

func _ready():

	role_manager = RoleManager.new()

	add_child(role_manager)

enum Phase {
	LOBBY,
	ROLE_REVEAL,
	NIGHT,
	MORNING,
	DISCUSSION,
	VOTING,
	EXECUTION,
	GAME_OVER
}

signal phase_changed(old_phase: Phase, new_phase: Phase)

var current_phase := Phase.LOBBY

var current_match := WerewolvesMatch.new()

func new_match() -> void:
	current_match = WerewolvesMatch.new()
	current_phase = Phase.LOBBY

func set_phase(new_phase: Phase) -> void:
	if current_phase == new_phase:
		return

	var old := current_phase
	current_phase = new_phase
	phase_changed.emit(old, new_phase)


static func get_phase_name(phase: Phase) -> String:
	match phase:
		Phase.LOBBY:
			return "Lobby"
		Phase.ROLE_REVEAL:
			return "Role Reveal"
		Phase.NIGHT:
			return "Night"
		Phase.MORNING:
			return "Morning"
		Phase.DISCUSSION:
			return "Discussion"
		Phase.VOTING:
			return "Voting"
		Phase.EXECUTION:
			return "Execution"
		Phase.GAME_OVER:
			return "Game Over"

	return "Unknown"

func create_test_match(player_count := 8):

	var builder := TestMatchBuilder.new()

	current_match = builder.build(
		player_count,
		role_manager
	)

	print_match()

func print_match():

	print("----------------------")

	for state in current_match.players:

		print(
			state.player.username,
			" -> ",
			state.role.display_name
		)

	print("----------------------")
