extends Control

signal customization_done(avatar_data: AvatarData)

@onready var preview: AvatarDisplay = $CenterContainer/Panel/MarginContainer/VBox/PreviewWrapper/Preview
@onready var hair_color_picker: ColorPickerButton = $CenterContainer/Panel/MarginContainer/VBox/HairColorRow/HairColorPicker
@onready var skin_color_picker: ColorPickerButton = $CenterContainer/Panel/MarginContainer/VBox/SkinToneRow/SkinColorPicker
@onready var done_button: Button = $CenterContainer/Panel/MarginContainer/VBox/DoneButton

@onready var hair_value_label: Label = $CenterContainer/Panel/MarginContainer/VBox/HairRow/ValueLabel
@onready var eyes_value_label: Label = $CenterContainer/Panel/MarginContainer/VBox/EyesRow/ValueLabel
@onready var mouth_value_label: Label = $CenterContainer/Panel/MarginContainer/VBox/MouthRow/ValueLabel
@onready var clothes_value_label: Label = $CenterContainer/Panel/MarginContainer/VBox/ClothesRow/ValueLabel

const HAIR_NAMES := {1: "Short"}
const EYES_NAMES := {1: "Round"}
const MOUTH_NAMES := {1: "Smile"}
const CLOTHES_NAMES := {1: "Tunic"}

var data: AvatarData

func _ready() -> void:
	data = SettingsManager.avatar_data.copy() if SettingsManager.avatar_data else AvatarData.new()

	hair_color_picker.color = data.hair_color
	skin_color_picker.color = data.skin_tone

	_wire_row("HairRow", _cycle_hair)
	_wire_row("EyesRow", _cycle_eyes)
	_wire_row("MouthRow", _cycle_mouth)
	_wire_row("ClothesRow", _cycle_clothes)

	hair_color_picker.color_changed.connect(func(c: Color):
		data.hair_color = c
		_refresh()
	)
	skin_color_picker.color_changed.connect(func(c: Color):
		data.skin_tone = c
		_refresh()
	)
	done_button.pressed.connect(_on_done)

	_refresh()

func _wire_row(row_name: String, cycle_func: Callable) -> void:
	var base := "CenterContainer/Panel/MarginContainer/VBox/%s/" % row_name
	var prev_btn := get_node(base + "PrevButton") as Button
	var next_btn := get_node(base + "NextButton") as Button
	prev_btn.pressed.connect(func(): cycle_func.call(-1))
	next_btn.pressed.connect(func(): cycle_func.call(1))

func _cycle_hair(dir: int) -> void:
	data.hair_style = wrapi(data.hair_style - 1 + dir, 0, HAIR_NAMES.size()) + 1
	hair_value_label.text = HAIR_NAMES.get(data.hair_style, "?")
	_refresh()

func _cycle_eyes(dir: int) -> void:
	data.eyes_style = wrapi(data.eyes_style - 1 + dir, 0, EYES_NAMES.size()) + 1
	eyes_value_label.text = EYES_NAMES.get(data.eyes_style, "?")
	_refresh()

func _cycle_mouth(dir: int) -> void:
	data.mouth_style = wrapi(data.mouth_style - 1 + dir, 0, MOUTH_NAMES.size()) + 1
	mouth_value_label.text = MOUTH_NAMES.get(data.mouth_style, "?")
	_refresh()

func _cycle_clothes(dir: int) -> void:
	data.clothes_style = wrapi(data.clothes_style - 1 + dir, 0, CLOTHES_NAMES.size()) + 1
	clothes_value_label.text = CLOTHES_NAMES.get(data.clothes_style, "?")
	_refresh()

func _refresh() -> void:
	preview.apply_avatar(data)

func _on_done() -> void:
	customization_done.emit(data)
