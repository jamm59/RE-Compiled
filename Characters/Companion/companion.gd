extends Node2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var dir: int  = Input.get_axis("Left", "Right")
	if dir == 0:
		return 
	animated_sprite_2d.flip_h = dir == -1
