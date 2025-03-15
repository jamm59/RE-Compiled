extends Node2D
class_name GateDoor

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func activate() -> void:
	animation_player.play("Open")
