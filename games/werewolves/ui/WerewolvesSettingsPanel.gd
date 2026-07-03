extends Control

@onready var mode_option: OptionButton = $VBox/ModeOptionButton

func get_settings() -> Dictionary:
	return {
		"role_pack": mode_option.get_item_text(mode_option.selected),
	}
