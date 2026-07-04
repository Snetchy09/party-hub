class_name PlayerData
extends Resource

@export var id: int = -1
@export var display_name: String = "Player"
@export var peer_id: int = -1
@export var is_host: bool = false
@export var is_online: bool = true
@export var is_ready: bool = false
var avatar_data: AvatarData = AvatarData.new()

func _init(p_id: int = -1, p_name: String = "Player") -> void:
	id = p_id
	peer_id = p_id
	display_name = p_name
	avatar_data = AvatarData.random()
