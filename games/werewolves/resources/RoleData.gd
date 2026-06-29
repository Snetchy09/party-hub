class_name RoleData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var team: String = ""         # e.g. "village", "werewolf"
@export var power: int = 0
@export var rarity: int = 1          # e.g. 1 (common), 2, 3 (rare)
@export var unique: bool = false     # true if only one allowed
@export var min_players: int = 1
@export var tags: Array[String] = [] # e.g. ["protector","night"]
@export var appears_good: bool = false
@export var appears_bad: bool = false
@export var can_act_at_night: bool = false
