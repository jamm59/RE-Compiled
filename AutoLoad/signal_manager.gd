extends Node


signal body_hit

signal large_fall_detected

signal remote_control_session_complete

signal terminal_control_signal_emit(pos: Vector2, name: String)

signal termianl_control_npc_signal(pos: Vector2, name: String)

signal termianl_control_education_signal(pos: Vector2, name: String, activate_multiple: bool)

signal player_dead

signal enemy_dead

signal last_checkpoint(name: String)

signal more_information_on_topic(topic: String)
