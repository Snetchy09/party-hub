extends Node

## TEMPORARY dev helper — auto-joins/hosts based on a launch argument.
## Usage: pass --testmode=host or --testmode=client:127.0.0.1 via
## Debug > Customize Run Instances... per-window arguments (Godot 4.3+),
## or just trigger manually with the F-key shortcuts below during dev.

const ENABLED := true  # flip to false before any real build

func _ready() -> void:
	if not ENABLED:
		return
	set_process_unhandled_key_input(true)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return
	var key_event := event as InputEventKey
	if key_event.keycode == KEY_F9:
		# F9 = quick host
		NetworkManager.create_server()
		print("[QuickTest] Hosting on port %s" % NetworkManager.PORT)
	elif key_event.keycode == KEY_F1:
		# F10 = quick join localhost
		NetworkManager.join_server("127.0.0.1")
		print("[QuickTest] Joining 127.0.0.1")
