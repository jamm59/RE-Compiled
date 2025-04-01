extends Area2D
class_name Bullet


var speed: float = 3.0
var dir_x: float = 0.0

var can_use: bool = true
var is_moving: bool = false

var DAMAGE_POINT: float = 2.0
	
func shoot(startLocation: Vector2, directionHorizontal: float):
	visible = true
	is_moving = true
	global_position = startLocation
	dir_x = directionHorizontal

func reset():
	visible = false
	is_moving = false
	
func _process(delta: float) -> void:
	if is_moving:
		visible = true
		global_position.x += dir_x * speed

func _on_body_entered(body: Node2D) -> void:
	reset()
	
	if body is Player:
		body.applyHitDamage(self)
		
