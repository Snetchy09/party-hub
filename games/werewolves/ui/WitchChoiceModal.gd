extends Control

@onready var white_button: Button = $CenterContainer/Panel/MarginContainer/VBox/WhiteButton
@onready var black_button: Button = $CenterContainer/Panel/MarginContainer/VBox/BlackButton

func _ready() -> void:
	white_button.pressed.connect(func(): _choose("white"))
	black_button.pressed.connect(func(): _choose("black"))

func _choose(choice: String) -> void:
	NetworkManager.send_to_host({"type": "witch_choice", "choice": choice})
	queue_free()
