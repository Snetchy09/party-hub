extends Node

func _ready():

	var manager := WerewolvesGameManager.new()

	add_child(manager)

	await get_tree().process_frame

	manager.create_test_match(8)
