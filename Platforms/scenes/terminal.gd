extends Node2D


@onready var gear_left: Sprite2D = $Lever/GearLeft
@onready var large: AnimatedSprite2D = $Lever/Large
@onready var small: AnimatedSprite2D = $Lever/Small
@onready var antenna: Sprite2D = $Lever/Antenna

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar

	
	
func _process(delta: float) -> void:
	if Input.is_action_pressed("Interact"):
		handleProgressBarAnimation()
		large.play("Spin")
		small.play("Spin")
		animation_player.play("Lever-pull")


func handleProgressBarAnimation() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(progress_bar, "value", 100, 3)
	await tween.finished
	animation_player.play_backwards("Lever-pull")
	
	
