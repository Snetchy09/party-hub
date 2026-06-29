# games/werewolves/systems/Action.gd
class_name Action
extends Node

var actor: WWPlayerState
var target: WWPlayerState
var action_type: String

func resolve() -> void:
	pass
