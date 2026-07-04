extends Node

const PORT := 7777
const MAX_CLIENTS := 20

signal client_connected(peer_id: int)
signal client_disconnected(peer_id: int)
signal message_received(sender_id: int, message: Dictionary)
signal connection_succeeded
signal connection_failed
signal server_disconnected

var _peer: ENetMultiplayerPeer
var is_host: bool = false
var is_active: bool = false

func create_server() -> Error:
	_peer = ENetMultiplayerPeer.new()
	var err := _peer.create_server(PORT, MAX_CLIENTS)
	if err != OK:
		push_error("NetworkManager: failed to create server, error %s" % err)
		return err
	multiplayer.multiplayer_peer = _peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	is_host = true
	is_active = true
	return OK

func join_server(ip: String) -> Error:
	_peer = ENetMultiplayerPeer.new()
	var err := _peer.create_client(ip, PORT)
	if err != OK:
		push_error("NetworkManager: failed to create client, error %s" % err)
		return err
	multiplayer.multiplayer_peer = _peer
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	is_host = false
	is_active = true
	return OK

func close() -> void:
	if _peer:
		_peer.close()
	multiplayer.multiplayer_peer = null
	is_active = false
	is_host = false

## Call this on a CLIENT to send something to the host.
func send_to_host(message: Dictionary) -> void:
	if not is_active:
		return

	var my_id := multiplayer.get_unique_id()
	# If I'm the host (or local peer 1), call the handler locally instead of RPCing to myself
	if is_host or my_id == 1:
		message_received.emit(my_id, message)
		return

	rpc_id(1, "_receive_message", message)  # peer 1 is always the host in ENet

func broadcast_to_all(message: Dictionary) -> void:
	if not is_active or not is_host:
		return
	message_received.emit(1, message)
	rpc("_receive_message", message)

func send_to_peer(peer_id: int, message: Dictionary) -> void:
	if not is_active or not is_host:
		return
	if peer_id == 1:
		# Host sending to itself — just emit locally, no RPC needed
		message_received.emit(1, message)
		return
	rpc_id(peer_id, "_receive_message", message)

@rpc("any_peer", "reliable", "call_remote")
func _receive_message(message: Dictionary) -> void:
	var sender_id := multiplayer.get_remote_sender_id()
	message_received.emit(sender_id, message)

func _on_peer_connected(peer_id: int) -> void:
	client_connected.emit(peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	client_disconnected.emit(peer_id)

func _on_connected_to_server() -> void:
	connection_succeeded.emit()

func _on_connection_failed() -> void:
	connection_failed.emit()

func _on_server_disconnected() -> void:
	server_disconnected.emit()

func get_my_peer_id() -> int:
	if not is_active:
		return 0
	return multiplayer.get_unique_id()

func get_connected_peer_ids() -> Array:
	if not is_active:
		return []
	return multiplayer.get_peers()

## Returns the device's local Wi-Fi IP (best guess) — shown to host so others can type it in.
func get_local_ip_guess() -> String:
	var addresses := IP.get_local_addresses()
	for addr in addresses:
		# Prefer typical home-network ranges
		if addr.begins_with("192.168.") or addr.begins_with("10.") or addr.begins_with("172."):
			return addr
	# Fallback: first non-loopback address
	for addr in addresses:
		if addr != "127.0.0.1" and not addr.begins_with("::"):
			return addr
	return "127.0.0.1"
