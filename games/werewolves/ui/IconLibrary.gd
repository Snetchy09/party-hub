class_name IconLibrary

const EMOJI := {
	"villager": "🧑‍🌾",
	"werewolf": "🐺",
	"witch": "🔮",
	"aura_seer": "👁️",
	"bloody_seer": "🩸",
	"judge": "⚖️",
	"jailer": "🔒",
	"mirror": "🪞",
	"medium": "👻",
	"streets_lady": "🌹",
	"hacker": "⚡",
	"jester": "🃏",
	"hunter": "🏹",
	"investigator": "🔍",
}

static func get_icon_text(role_id: String) -> String:
	return EMOJI.get(role_id, "❓")
