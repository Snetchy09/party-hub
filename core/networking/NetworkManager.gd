extends Node

var _server: TCPServer
var _clients: Dictionary = {}  # peer_id -> StreamPeer
var _server_connection: StreamPeerTCP
var _message_queue: Array = []
var _is_server: bool = false
var _is_client: bool = false

signal message_received(from_id: int, message: Dictionary)
signal client_connected(peer_id: int, player_name: String)
signal client_disconnected(peer_id: int)

func start_server(port: int) -> void:
	_server = TCPServer.new()
	_server.listen(port)
	_is_server = true
	print("Server listening on port %d" % port)

func connect_to_server(host_ip: String, port: int, player_name: String) -> void:
	_server_connection = StreamPeerTCP.new()
	_server_connection.connect_to_host(host_ip, port)
	_is_client = true
	print("Connecting to %s:%d as %s" % [host_ip, port, player_name])

func _process(delta: float) -> void:
	if _is_server:
		_process_server()
	if _is_client:
		_process_client()

func _process_server() -> void:
	# Check for new connections
	if _server.is_connection_available():
		var peer = _server.take_connection()
		var peer_id = peer.get_meta("peer_id", randi())
		_clients[peer_id] = peer
		print("Client connected: %d" % peer_id)
		message_received.emit(peer_id, {"type": "client_connect"})
	
	# Check for messages from clients
	for peer_id in _clients.keys():
		var peer = _clients[peer_id]
		if peer.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			if peer.get_available_bytes() > 0:
				var data = peer.get_string(peer.get_available_bytes())
				var message = JSON.parse_string(data)
				message_received.emit(peer_id, message)

func _process_client() -> void:
	if _server_connection.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		if _server_connection.get_available_bytes() > 0:
			var data = _server_connection.get_string(_server_connection.get_available_bytes())
			var message = JSON.parse_string(data)
			message_received.emit(0, message)  # 0 = host peer_id

func send_message(peer_id: int, message: Dictionary) -> void:
	if _is_server:
		if _clients.has(peer_id):
			_clients[peer_id].put_string(JSON.stringify(message))
	elif _is_client:
		_server_connection.put_string(JSON.stringify(message))

func broadcast_to_all(message: Dictionary) -> void:
	if not _is_server:
		return
	for peer_id in _clients.keys():
		send_message(peer_id, message)
