extends Node2D
class_name CoinReward
@onready var animated_sprite_2d: AnimatedSprite2D = $Parent/AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animated_sprite_2d.play(["Gold", "Dark"].pick_random())
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.update_coin()
		animation_player.play("Coin")
		
