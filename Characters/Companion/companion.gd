extends Node2D
class_name Companion

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var companionCanFollowPlayer: bool = false

enum CompanionState {IDLE, MOVE}

var state: CompanionState = CompanionState.IDLE
# Called every frame. 'delta' is the elapsed time since the previous frame.

func handleInput() -> void:
	if not companionCanFollowPlayer:
		return 
	var dir: float  = Input.get_axis("Left", "Right")
	if dir == 0.0:
		state = CompanionState.IDLE
	else:
		state = CompanionState.MOVE
		animated_sprite_2d.flip_h = true if dir > 0.0 else false
		
func handleAnimationState() -> void:
	match state:
		CompanionState.IDLE:
			animated_sprite_2d.play("Idle")
		CompanionState.MOVE:
			animated_sprite_2d.play("Move")
			
		
func _process(delta: float) -> void:
	handleInput()
	handleAnimationState()
