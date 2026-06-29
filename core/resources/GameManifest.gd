class_name GameManifest
extends Resource

@export var id: String = ""

@export var display_name: String = ""

@export_multiline var description: String = ""

@export_range(2, 100)
var min_players: int = 2

@export_range(2, 100)
var max_players: int = 20

@export var version: String = "1.0.0"

@export var author: String = ""

@export var icon: Texture2D

@export var main_scene: PackedScene
