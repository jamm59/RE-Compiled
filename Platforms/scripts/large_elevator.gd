extends Node2D
class_name LargeElevator

enum DIRECTION {HORIZONTAL, VERTICAL}

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var movement: bool = false
@export var reverse_movement: bool = false
@export var direction: DIRECTION = DIRECTION.VERTICAL

func _ready() -> void:
	if movement:
		activate()

func activate() -> void:
	match direction:
		DIRECTION.HORIZONTAL:
			if not reverse_movement:
				animation_player.play("left-right")
			else:
				animation_player.play_backwards("left-right")
		DIRECTION.VERTICAL:
			if not reverse_movement:
				animation_player.play("up-down")
			else:
				animation_player.play_backwards("up-down")
		
