extends Node2D
class_name SwingHammer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
const DAMAGE_POINT: int = 10


func activate() -> void:
	animation_player.stop()
	animation_player.play_backwards("RESET")


func _on_kill_damage_body_entered(body: Node2D) -> void:
	if body is Player:
		body.applyHitDamage(self)
