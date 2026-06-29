# games/werewolves/systems/actions/ProtectAction.gd
class_name ProtectAction
extends Action

func _init() -> void:
	action_type = "protect"

func resolve() -> void:
	target.statuses["protected"] = true
	print("%s is now protected" % target.player.name)
