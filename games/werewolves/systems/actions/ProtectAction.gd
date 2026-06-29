class_name ProtectAction
extends Action

func _init() -> void:
	action_type = "protect"

func resolve() -> void:
	if target == null:
		return
	target.statuses["protected"] = true  # ← CHANGE TO Dictionary
	print("%s protected %s" % [actor.player.name, target.player.name])
