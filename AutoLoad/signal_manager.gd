extends Node

signal npc_dead 

signal body_hit

signal enemy_dead

signal player_dead

signal searching_signal

signal large_fall_detected

signal last_checkpoint(name: String)

signal remote_control_session_complete

signal more_information_on_topic(topic: String)

signal terminal_control_signal_emit(pos: Vector2, name: String)

signal termianl_control_npc_signal(pos: Vector2, name: String)

signal termianl_control_education_signal(pos: Vector2, name: String, activate_multiple: bool)
