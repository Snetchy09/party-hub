extends PanelContainer
class_name SecretChatUI

@onready var messages_container: VBoxContainer = $VBox/ScrollContainer/MessagesContainer
@onready var input_field: LineEdit = $VBox/HBox/InputField
@onready var send_button: Button = $VBox/HBox/SendButton

var my_player_id: int = -1

func _ready() -> void:
	send_button.pressed.connect(_on_send_pressed)
	input_field.text_submitted.connect(func(_t): _on_send_pressed())

func setup(player_id: int) -> void:
	my_player_id = player_id

func receive_message(msg: Dictionary) -> void:
	var label := Label.new()
	var sender_tag := "You" if msg["sender_id"] == my_player_id else "Them"
	label.text = "[%s]: %s" % [sender_tag, msg["text"]]
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	messages_container.add_child(label)

func _on_send_pressed() -> void:
	var text := input_field.text.strip_edges()
	if text.is_empty():
		return
	NetworkManager.send_to_host({"type": "chat_message", "text": text})
	input_field.text = ""
