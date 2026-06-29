class_name InvestigateAction
extends Action

func _init() -> void:
	action_type = "investigate"

func resolve() -> void:
	if target == null or target.role == null:
		return
	
	var alignment = "unknown"
	if target.role.team == "village":
		alignment = "good"
	elif target.role.team == "werewolves":
		alignment = "bad"
	
	print("%s investigated %s: %s" % [actor.player.name, target.player.name, alignment])
	actor.statuses["investigated_%s" % alignment] =  true
