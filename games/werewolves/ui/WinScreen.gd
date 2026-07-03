extends Control

@onready var winner_label: Label = $CenterContainer/VBox/WinnerLabel
@onready var reason_label: Label = $CenterContainer/VBox/ReasonLabel
@onready var all_roles_grid: PlayerGridUI = $CenterContainer/VBox/AllRolesGrid
@onready var play_again_button: Button = $CenterContainer/VBox/PlayAgainButton
@onready var menu_button: Button = $CenterContainer/VBox/MenuButton

const WINNER_TEXT := {
	"village": "🏘️ VILLAGE WINS!",
	"werewolves": "🐺 WEREWOLVES WIN!",
	"jester": "🃏 THE JESTER WINS!",
	"hunter": "🏹 THE HUNTER WINS!",
	"hacker": "⚡ THE HACKER WINS!",
}

func _ready() -> void:
	play_again_button.pressed.connect(_on_play_again)
	menu_button.pressed.connect(_on_menu)

func initialize(message: Dictionary) -> void:
	var winner: String = message.get("winner", "")
	winner_label.text = WINNER_TEXT.get(winner, "GAME OVER")
	reason_label.text = message.get("reason", "")

	var cards := []
	for c in message.get("all_cards", []):
		cards.append({
			"player_id": c["player_id"],
			"name": c["name"],
			"avatar_seed": 0,
			"alive": c.get("alive", false),
			"role": c.get("role", ""),
			"role_display": c.get("role_display", ""),
			"role_revealed": true,
			"statuses": [],
		})
	all_roles_grid.update_from_state(cards)
	all_roles_grid.set_cards_selectable(false)

func _on_play_again() -> void:
	NetworkManager.close()
	GameManager.end_match()
	SceneManager.change_screen(Screens.MAIN_MENU)

func _on_menu() -> void:
	NetworkManager.close()
	GameManager.end_match()
	SceneManager.change_screen(Screens.MAIN_MENU)
