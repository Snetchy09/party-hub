extends Control
class_name AvatarDisplay

@onready var body_rect: TextureRect = $Body
@onready var clothes_rect: TextureRect = $Clothes
@onready var hair_back_rect: TextureRect = $HairBack
@onready var eyes_rect: TextureRect = $Eyes
@onready var mouth_rect: TextureRect = $Mouth
@onready var hair_front_rect: TextureRect = $HairFront

const HAIR_PATH := "res://assets/avatar_parts/hair/hair_%02d_%s.png"
const EYES_PATH := "res://assets/avatar_parts/eyes/eyes_%02d_%s.png"
const MOUTH_PATH := "res://assets/avatar_parts/mouth/mouth_%02d_%s.png"
const CLOTHES_PATH := "res://assets/avatar_parts/clothes/clothes_%02d_%s.png"
const BODY_PATH := "res://assets/avatar_parts/body/body_default.png"

## Until you've drawn real files, these stay safely empty (TextureRect with
## no texture just renders nothing — no crash). Fill in real filenames as
## you draw them; this dictionary is the ONLY place you register new parts.
const HAIR_FILES := {1: "short"}   #{1: "short", 2: "long", 3: "curly"}
const EYES_FILES := {1: "round"}
const MOUTH_FILES := {1: "smile"}
const CLOTHES_FILES := {1: "tunic"}

func apply_avatar(data: AvatarData) -> void:
	body_rect.texture = _safe_load(BODY_PATH)
	body_rect.modulate = data.skin_tone

	clothes_rect.texture = _safe_load(CLOTHES_PATH % [data.clothes_style, CLOTHES_FILES.get(data.clothes_style, "tunic")])

	var hair_tex := _safe_load(HAIR_PATH % [data.hair_style, HAIR_FILES.get(data.hair_style, "short")])
	hair_back_rect.texture = hair_tex
	hair_back_rect.modulate = data.hair_color
	hair_front_rect.texture = hair_tex
	hair_front_rect.modulate = data.hair_color

	eyes_rect.texture = _safe_load(EYES_PATH % [data.eyes_style, EYES_FILES.get(data.eyes_style, "round")])
	mouth_rect.texture = _safe_load(MOUTH_PATH % [data.mouth_style, MOUTH_FILES.get(data.mouth_style, "smile")])

func _safe_load(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null  # silently render nothing until you've drawn this file
	return load(path)
