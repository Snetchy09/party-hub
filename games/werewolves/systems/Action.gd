# games/werewolves/systems/Action.gd
class_name Action
extends Node

var actor: GameSession.WWPlayerState
var target: GameSession.WWPlayerState
var action_type: String

func resolve() -> void:
	pass
