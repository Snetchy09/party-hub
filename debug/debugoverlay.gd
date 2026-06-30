extends CanvasLayer

const ENABLED := false

var label: Label

func _ready() -> void:
	if not ENABLED:
		queue_free()
		return
	layer = 100  # always on top
	label = Label.new()
	label.add_theme_font_size_override("font_size", 14)
	label.modulate = Color(0, 1, 0)
	label.position = Vector2(10, 10)
	add_child(label)
	set_process(true)

func _process(_delta: float) -> void:
	if not is_instance_valid(label):
		return
	var peer_id := NetworkManager.get_my_peer_id()
	var role_text := "HOST" if NetworkManager.is_host else "CLIENT"
	var active_text := "ACTIVE" if NetworkManager.is_active else "idle"
	label.text = "[%s] peer_id=%s (%s)" % [role_text, peer_id, active_text]
