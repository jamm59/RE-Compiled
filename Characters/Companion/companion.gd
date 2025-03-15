extends Node2D
class_name Companion

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var companionCanFollowPlayer: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not companionCanFollowPlayer:
		return 
	var dir: float  = Input.get_axis("Left", "Right")
	
	if dir > 0.0:
		animated_sprite_2d.flip_h = false
	elif dir < 0.0:
		animated_sprite_2d.flip_h = true
