class_name NetworkManager
extends RefCounted

signal message_received(peer_id: int, message: Dictionary)

func broadcast_to_all(message: Dictionary) -> void:
	print("[BROADCAST] %s" % message)

func send_to_peer(peer_id: int, message: Dictionary) -> void:
	print("[SEND to %d] %s" % [peer_id, message])
