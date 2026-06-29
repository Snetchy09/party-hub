extends Control


@onready var fire := $Campfire/Fire


func _ready():
	animate_fire()


func animate_fire():
	var tween = create_tween()

	tween.set_loops()

	tween.tween_property(
		fire,
		"scale",
		Vector2(1.08, 0.92),
		0.45
	)

	tween.tween_property(
		fire,
		"scale",
		Vector2.ONE,
		0.45
	)
