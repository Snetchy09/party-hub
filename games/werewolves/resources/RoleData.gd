class_name RoleData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var team: String = "village"          # "village" | "werewolves" | "solo" | "village_or_werewolves"
@export var appears_as: String = "good"        # "good" | "bad" | "unknown"
@export var power: int = 1
@export var rarity: int = 1
@export var unique: bool = false
@export var min_players: int = 4
@export var can_act_at_night: bool = false
@export var can_act_at_day: bool = false
@export var night_action: String = ""
@export var day_action: String = ""
@export var night_uses: int = -1               # -1 = unlimited
@export var tags: Array[String] = []
@export var icon: String = ""                  # lookup key, see IconLibrary in Part 6

func from_dict(d: Dictionary) -> void:
	id = d.get("id", "")
	display_name = d.get("display_name", "")
	description = d.get("description", "")
	team = d.get("team", "village")
	appears_as = d.get("appears_as", "good")
	power = d.get("power", 1)
	rarity = d.get("rarity", 1)
	unique = d.get("unique", false)
	min_players = d.get("min_players", 4)
	can_act_at_night = d.get("can_act_at_night", false)
	can_act_at_day = d.get("can_act_at_day", false)
	night_action = d.get("night_action", "")
	day_action = d.get("day_action", "")
	night_uses = d.get("night_uses", -1)
	icon = d.get("icon", "")
	var tag_array = d.get("tags", [])
	tags.clear()
	for t in tag_array:
		tags.append(String(t))

func get_localized_name() -> String:
	return tr("ROLE_%s_NAME" % id.to_upper())

func get_localized_description() -> String:
	return tr("ROLE_%s_DESC" % id.to_upper())
