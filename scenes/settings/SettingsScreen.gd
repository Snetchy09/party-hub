extends BaseScreen

@onready var name_input: LineEdit = $MarginContainer/VBox/NameInput
@onready var language_option: OptionButton = $MarginContainer/VBox/LanguageOption
@onready var back_button: Button = $MarginContainer/VBox/BackButton

func _ready() -> void:
	name_input.text = SettingsManager.player_name
	name_input.text_changed.connect(_on_name_changed)
	back_button.pressed.connect(_on_back)

	_populate_languages()
	language_option.item_selected.connect(_on_language_selected)

func _populate_languages() -> void:
	language_option.clear()
	for i in range(LocaleManager.AVAILABLE_LOCALES.size()):
		var locale_code: String = LocaleManager.AVAILABLE_LOCALES[i]
		language_option.add_item(LocaleManager.LOCALE_DISPLAY_NAMES.get(locale_code, locale_code))
		if locale_code == SettingsManager.language:
			language_option.select(i)

func _on_language_selected(index: int) -> void:
	var locale_code: String = LocaleManager.AVAILABLE_LOCALES[index]
	LocaleManager.set_locale(locale_code)
	SettingsManager.language = locale_code
	SettingsManager.save_settings()

func _on_name_changed(new_text: String) -> void:
	SettingsManager.player_name = new_text

func _on_back() -> void:
	SettingsManager.save_settings()
	SceneManager.change_screen(Screens.MAIN_MENU)
