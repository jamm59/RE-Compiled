extends Area2D
class_name Bullet

@export var speed: float = 1.0

var DAMAGE_POINT: float = 2.0

var dir_x: float = 0.0
var dir_y: float = 0.0
var can_use: bool = true
var is_moving: bool = false
		
func _process(delta: float) -> void:
	if is_moving:
		visible = true
		global_position += Vector2(dir_x, dir_y) * speed
		
		
func shoot(startLocation: Vector2, angle: float):
	visible = true
	is_moving = true
	global_position = startLocation
	dir_x = cos(angle)
	dir_y = sin(angle)
	
	print(dir_y)

func reset():
	visible = false
	is_moving = false
	

func _on_body_entered(body: Node2D) -> void:
	reset()
	if body is Player:
		body.applyHitDamage(self)
		
