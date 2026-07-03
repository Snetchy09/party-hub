extends Node

## Add new language codes here as you support more languages.
## This single array is the only place you need to touch when adding a language —
## as long as the CSV also has a matching column.
const AVAILABLE_LOCALES := ["en", "ar", "fr"]

const LOCALE_DISPLAY_NAMES := {
	"en": "English",
	"ar": "العربية",
	"fr": "Français",
}

const RTL_LOCALES := ["ar"]  # add other RTL languages here if you support them later (he, fa, ur...)

func _ready() -> void:
	var saved_locale: String = SettingsManager.language
	if saved_locale == "" or saved_locale not in AVAILABLE_LOCALES:
		saved_locale = _detect_system_locale()
	set_locale(saved_locale)

func _detect_system_locale() -> String:
	var system_locale := OS.get_locale_language()  # e.g. "en", "ar", "fr"
	if system_locale in AVAILABLE_LOCALES:
		return system_locale
	return "en"

func set_locale(locale_code: String) -> void:
	if locale_code not in AVAILABLE_LOCALES:
		push_warning("LocaleManager: unsupported locale '%s', falling back to 'en'" % locale_code)
		locale_code = "en"

	TranslationServer.set_locale(locale_code)

func is_rtl() -> bool:
	return TranslationServer.get_locale() in RTL_LOCALES

func current_locale() -> String:
	return TranslationServer.get_locale()
