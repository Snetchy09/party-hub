class_name WWPlayerState
extends RefCounted

var player: PlayerData

var role: RoleData

var alive := true

var protected := false
var jailed := false
var cursed := false
var silenced := false

func _init(player_data: PlayerData):
	player = player_data
