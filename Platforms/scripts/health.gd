extends Node2D
class_name PowerUP

@onready var animation_player: AnimationPlayer = $AnimationPlayer

const POWER_UP_VALUE: float = 4.0

func _ready() -> void:
	animation_player.play("hover")
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		animation_player.play("powerUP")
		body.apply_power_up(POWER_UP_VALUE)
