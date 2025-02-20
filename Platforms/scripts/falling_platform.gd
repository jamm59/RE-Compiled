extends Node2D
@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		timer.start()


func _on_timer_timeout() -> void:
	animation_player.play("Disappear")
