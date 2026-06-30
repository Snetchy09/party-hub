class_name MessageTypes

# Client → Host
const PLAYER_HELLO := "player_hello"
const NIGHT_ACTION := "night_action"
const VOTE := "vote"
const WITCH_CHOICE := "witch_choice"
const INVESTIGATOR_GROUP := "investigator_group"
const CHAT_MESSAGE := "chat_message"
const JUDGE_SKIP := "judge_skip"
const JUDGE_FREE := "judge_free"
const JAILER_TARGET := "jailer_target"
const JAILER_KILL := "jailer_kill"
const HACKER_TARGET := "hacker_target"
const READY_TOGGLE := "ready_toggle"

# Host → Client(s)
const LOBBY_STATE := "lobby_state"
const GAME_START := "game_start"
const STATE_UPDATE := "state_update"
const PHASE_CHANGE := "phase_change"
const ANNOUNCEMENT := "announcement"
const SECRET_CHAT_MESSAGE := "secret_chat_message"
const GAME_END := "game_end"
const ERROR := "error"
