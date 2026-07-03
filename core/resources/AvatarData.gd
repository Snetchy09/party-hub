class_name AvatarData
extends RefCounted

var hair_style: int = 1       # index into hair/ folder, 1-based
var hair_color: Color = Color(0.4, 0.25, 0.1)  # default brown
var eyes_style: int = 1
var mouth_style: int = 1
var clothes_style: int = 1
var skin_tone: Color = Color(0.93, 0.78, 0.62)  # applied to body layer

func to_dict() -> Dictionary:
	return {
		"hair_style": hair_style,
		"hair_color": hair_color.to_html(false),
		"eyes_style": eyes_style,
		"mouth_style": mouth_style,
		"clothes_style": clothes_style,
		"skin_tone": skin_tone.to_html(false),
	}

func from_dict(d: Dictionary) -> void:
	hair_style = d.get("hair_style", 1)
	hair_color = Color(d.get("hair_color", "664019"))
	eyes_style = d.get("eyes_style", 1)
	mouth_style = d.get("mouth_style", 1)
	clothes_style = d.get("clothes_style", 1)
	skin_tone = Color(d.get("skin_tone", "edc79e"))

static func random() -> AvatarData:
	var a := AvatarData.new()
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	a.hair_style = rng.randi_range(1, 1)   # adjust max once you've drawn more options
	a.eyes_style = rng.randi_range(1, 1)
	a.mouth_style = rng.randi_range(1, 1)
	a.clothes_style = rng.randi_range(1, 1)
	a.hair_color = Color.from_hsv(rng.randf(), 0.6, 0.5)
	return a

func copy() -> AvatarData:
	var a := AvatarData.new()
	a.hair_style = hair_style
	a.hair_color = hair_color
	a.eyes_style = eyes_style
	a.mouth_style = mouth_style
	a.clothes_style = clothes_style
	a.skin_tone = skin_tone
	return a
