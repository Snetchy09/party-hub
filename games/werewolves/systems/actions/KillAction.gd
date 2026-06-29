# games/werewolves/systems/actions/KillAction.gd
class_name KillAction
extends Action

func _init() -> void:
	action_type = "kill"

func resolve() -> void:
	if target.statuses.get("protected", false):
		print("%s tried to kill %s, but they were protected!" % [actor.player.name, target.player.name])
		target.statuses["protected"] = false
		return
	
	target.alive = false
	print("%s was killed!" % target.player.name)
