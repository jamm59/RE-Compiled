@tool
extends Node2D
class_name TerminalControlBase

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar: ProgressBar = $MarginContainer/ProgressBar

@export var specific_platform_name: String = ""

var radius: float = 0
var hasActivatedTerminal: bool = false
var canActivateTerminal: bool = false
var bodyEntered: Node2D 
	
func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_arc(Vector2.ZERO, radius, 0, 360, 100, Color(1, 1, 1, 0.7), 20, true )
	
func _input(event: InputEvent) -> void:
	if (canActivateTerminal and Input.is_action_just_pressed("Interact")) and not hasActivatedTerminal:
		handleProgressBarAnimation()
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
	SignalManager.emit_signal("terminal_control_signal_emit", global_position, specific_platform_name)
	
	if bodyEntered is NPCBase:
		SignalManager.emit_signal("remote_control_session_complete")
		bodyEntered.remote_control_activated = false
		bodyEntered.queue_free()
		canActivateTerminal = false
		hasActivatedTerminal = false
		

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player or body is NPCBase:
		canActivateTerminal = true
		bodyEntered = body
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player or body is NPCBase:
		canActivateTerminal = false
