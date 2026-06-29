class_name RoleData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""

@export var alignment: String = ""
@export var power: int = 0

@export var appears_good: bool = true
@export var appears_bad: bool = false

@export var can_act_at_night: bool = false
