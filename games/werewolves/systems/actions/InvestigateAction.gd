# games/werewolves/systems/actions/InvestigateAction.gd
class_name InvestigateAction
extends Action

func _init() -> void:
	action_type = "investigate"

func resolve() -> void:
	# Blue Seer learns alignment (good/bad/unknown)
	var alignment = "unknown"
	if target.role.team == "village":
		alignment = "good"
	elif target.role.team == "werewolves":
		alignment = "bad"
	
	print("%s investigated %s: %s" % [actor.player.name, target.player.name, alignment])
	
	# Store investigation result (for displaying to Blue Seer in morning)
	actor.statuses["investigation_result"] = alignment
