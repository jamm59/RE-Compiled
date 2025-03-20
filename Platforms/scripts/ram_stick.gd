extends Node2D
class_name CoinReward
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		queue_free()
		#animation_player.play("Collect")
		#body.
