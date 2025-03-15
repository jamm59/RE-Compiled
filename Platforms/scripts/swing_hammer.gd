extends Node2D
class_name SwingHammer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func activate() -> void:
	animation_player.stop()
	animation_player.play_backwards("RESET")
