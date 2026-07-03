class_name ChatManager
extends RefCounted

var jailer_chat: Array[Dictionary] = []
var medium_chat: Array[Dictionary] = []
var jailer_id: int = -1
var jailed_id: int = -1

func open_jailer_chat(jailer: int, jailed: int) -> void:
	jailer_id = jailer
	jailed_id = jailed
	jailer_chat.clear()

func send_jailer_message(sender_id: int, text: String) -> Dictionary:
	if sender_id != jailer_id and sender_id != jailed_id:
		return {}
	var msg := {"sender_id": sender_id, "text": text, "time": Time.get_ticks_msec()}
	jailer_chat.append(msg)
	return msg

func send_medium_message(sender_id: int, text: String) -> Dictionary:
	var msg := {"sender_id": sender_id, "text": text, "time": Time.get_ticks_msec()}
	medium_chat.append(msg)
	return msg

func clear_night_chats() -> void:
	jailer_chat.clear()
	jailer_id = -1
	jailed_id = -1
