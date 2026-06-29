class_name WerewolvesGameManager
extends Node

var role_manager: RoleManager
var current_match: WerewolvesMatch

func _ready():
	role_manager = RoleManager.new()
	add_child(role_manager)
	# Optionally, auto-start a test match:
	create_test_match(8)

func create_test_match(player_count: int = 8) -> void:
	var builder := TestMatchBuilder.new()
	current_match = builder.build(player_count, role_manager)
	print_match()

func print_match():
	print("----------------------")
	for state in current_match.players:
		print(state.player.username, " -> ", state.role.display_name)
	print("----------------------")
