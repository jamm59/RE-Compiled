@tool
extends Node2D


@onready var medium: AnimatedSprite2D = $Gears/Medium

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar: ProgressBar = $Gears/MarginContainer/ProgressBar


var radius: float = 0
var hasActivatedTerminal: bool = false
var canActivateTerminal: bool = false
	
func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_arc(Vector2.ZERO, radius, 0, 360, 100, "#b7b39d", 2, true )
	
func _input(event: InputEvent) -> void:
	if (canActivateTerminal and event.is_action_pressed("Interact")) and not hasActivatedTerminal:
		handleProgressBarAnimation()
		medium.play("Spin")
		animation_player.play("Lever-pull")

func handleProgressBarAnimation() -> void:
	if hasActivatedTerminal:
		return 
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(progress_bar, "value", 100, 2)
	tween.tween_property(self, "radius", 5000, 3)
	await tween.finished
	# Reset the radius to delete the arc
	radius = 0
	hasActivatedTerminal = true
	animation_player.play_backwards("Lever-pull")
	SignalManager.emit_signal("terminal_control_signal_emit", global_position)
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		canActivateTerminal = true
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		canActivateTerminal = false
