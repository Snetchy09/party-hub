class_name PHButton
extends Button

@export var press_scale := 0.96
@export var animation_time := 0.08

var _original_scale := Vector2.ONE


func _ready() -> void:
	_original_scale = scale

	button_down.connect(_pressed_animation)
	button_up.connect(_released_animation)


func _pressed_animation() -> void:
	create_tween().tween_property(
		self,
		"scale",
		_original_scale * press_scale,
		animation_time
	)


func _released_animation() -> void:
	create_tween().tween_property(
		self,
		"scale",
		_original_scale,
		animation_time
	)
