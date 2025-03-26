@tool
extends Node2D
class_name QuestionTermainalBase

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var specific_platform_name: String = ""

var hasActivatedTerminal: bool = false
var canActivateTerminal: bool = false
var bodyEntered: Node2D 
	

func _input(event: InputEvent) -> void:
	if (canActivateTerminal and Input.is_action_just_pressed("Interact")) and not hasActivatedTerminal:
		handleProgressBarAnimation()
		animation_player.play("Lever-pull")

func handleProgressBarAnimation() -> void:
	if hasActivatedTerminal:
		return 
	
	await get_tree().create_timer(2).timeout
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
