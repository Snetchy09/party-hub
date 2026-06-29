class_name NetworkMessageHandler
extends RefCounted

var phase_manager: PhaseManager
var match_manager: MatchManager

func handle_message(peer_id: int, message: Dictionary) -> void:
	match message.get("type", ""):
		"action":
			phase_manager.submit_night_action(
				message["player_id"],
				message["action_type"],
				message["target_id"]
			)
		"vote":
			phase_manager.submit_vote(
				message["player_id"],
				message["voted_for_id"]
			)

func broadcast_state(network_manager: NetworkManager) -> void:
	var state = match_manager.get_card_state()
	network_manager.broadcast_to_all({
		"type": "state_update",
		"state": state
	})
