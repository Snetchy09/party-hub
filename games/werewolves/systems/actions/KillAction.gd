class_name KillAction
extends Action

func _init() -> void:
	action_type = "kill"

func resolve() -> void:
	if target == null:
		return
	if target.statuses.get("protected", false):  # ← CHANGE TO Dictionary access
		print("%s tried to kill %s, but they were protected!" % [actor.player.name, target.player.name])
		target.statuses.erase("protected")
		return
	
	target.alive = false  # ← CHANGE FROM death_cause to alive flag
	target.death_cause = "night kill"
	print("%s was killed!" % target.player.name)
