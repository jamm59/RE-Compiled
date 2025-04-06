extends Node2D
class_name SwitchButtonControl

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var progress_bar: ProgressBar = $MarginContainer/ProgressBar
@onready var button: AnimatedSprite2D = $Button
@onready var gear_4: AnimatedSprite2D = $Extra/Gear4
@onready var gear_5: AnimatedSprite2D = $Extra/Gear5
@onready var gear_3: AnimatedSprite2D = $Extra/Gear3

@export var specific_platform_name: String = ""

var bodyEntered: Node2D

var radius: float = 0
var hasActivatedTerminal: bool = false
var canActivateTerminal: bool = false
	
	
func _input(event: InputEvent) -> void:
	if (canActivateTerminal and event.is_action_pressed("Interact")) and not hasActivatedTerminal:
		handleProgressBarAnimation()


func handleProgressBarAnimation() -> void:
	if hasActivatedTerminal:
		return 
	button.play("Activate")
	audio_stream_player_2d.playing = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(progress_bar, "value", 100, 1)
	await tween.finished
	
	# Reset the radius to delete the arc
	gear_3.play("Spin")
	gear_4.play_backwards("Spin")
	gear_5.play("Spin")
	button.play_backwards("Activate")
	radius = 0
	hasActivatedTerminal = true
	SignalManager.emit_signal("terminal_control_signal_emit", global_position, specific_platform_name)
	
	if bodyEntered is NPCBase:
		SignalManager.emit_signal("remote_control_session_complete")
		bodyEntered.remote_control_activated = false
		bodyEntered.queue_free()
		canActivateTerminal = false
		hasActivatedTerminal = false
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player or (body is NPCBase and body.remote_control_activated):
		canActivateTerminal = true
		bodyEntered = body
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player or (body is NPCBase and body.remote_control_activated):
		canActivateTerminal = false
