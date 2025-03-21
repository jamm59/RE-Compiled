@tool
extends Node2D
class_name ShortRangeTerminal

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var hover: bool = true
@export var usable: bool = false
@export var specific_platform_name: String = ""

var radius = 0

func _ready() -> void:
	if not hover:
		animation_player.play("RESET")
	else:
		visible = true
		
func _input(event: InputEvent) -> void:
	if hover or not usable:
		return 

	if Input.is_action_just_pressed("Interact-Short"):
		handleEmitAnimation()

func _process(delta: float) -> void:
	if hover or not usable:
		return
	queue_redraw()
	
func _draw() -> void:
	draw_arc(Vector2.ZERO, radius, 0, 360, 100, Color(1, 1, 1, 0.7), 10, true )

func handleEmitAnimation() -> void:
	visible = true
	animation_player.play("Activate")
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "radius", 2000, 3)
	await tween.finished
	# Reset the radius to delete the arc
	visible = false
	radius = 0
	animation_player.play_backwards("Activate")
	SignalManager.emit_signal("termianl_control_npc_signal", global_position, specific_platform_name)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and hover:
		await get_tree().create_timer(0.2).timeout
		queue_free()
