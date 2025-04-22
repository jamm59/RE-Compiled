extends CharacterBody2D
class_name Bullet

@onready var ball_bullet: AnimatedSprite2D = $BallBullet
@onready var straight_bullet: Sprite2D = $StraightBullet

@export var speed: float = 100.0
@export var from_companion: float = false

var DAMAGE_POINT: float = 2


var dir_x: float = 0.0
var dir_y: float = 0.0
var can_use: bool = true
var is_moving: bool = false

func _physics_process(delta: float) -> void:
	velocity += Vector2(dir_x, dir_y) * speed
	move_and_slide()

		
func shoot(startLocation: Vector2, angle: float):
	visible = true
	is_moving = true
	global_position = startLocation
	dir_x = cos(angle) 
	dir_y = sin(angle)
	
	if from_companion:
		speed = 50.0
		ball_bullet.visible = true
		straight_bullet.visible = false
	else:
		ball_bullet.visible = false
		straight_bullet.visible = true
		if dir_x > 0.0:
			# Set flip_v to false when moving right
			straight_bullet.flip_v = false
		elif dir_x < 0.0:
			# Set flip_v to true when moving left
			straight_bullet.flip_v = true


func reset():
	visible = false
	is_moving = false
	queue_free()
	
func _on_explosion_animation_finished() -> void:
	$Explosion.play("none")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is TileMapLayer or body is EnemyBase:
		reset()
	if body is EnemyDuplicate:
		body.apply_damage(body.health)
	if body is EnemyBase:
		body.apply_damage(DAMAGE_POINT)
