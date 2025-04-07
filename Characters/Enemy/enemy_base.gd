extends CharacterBody2D
class_name EnemyBase

const HEALTH = preload("res://Platforms/scenes/health.tscn")

@export_category("Jump Settings")
@export var jump_height : float = 40
@export var jump_time_to_peak : float = 0.3
@export var jump_time_to_descent : float = 0.3

@onready var JUMP_VELOCITY : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var JUMP_GRAVITY : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var FALL_GRAVITY : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
@onready var FALL_GRAVITY_TEMP = FALL_GRAVITY

@onready var ray_cast_right: RayCast2D = $RayCast/RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCast/RayCastLeft
@onready var ray_cast_left_ground: RayCast2D = $RayCast/RayCastLeftGround
@onready var ray_cast_right_ground: RayCast2D = $RayCast/RayCastRightGround
@onready var ray_cast_top_right: RayCast2D = $RayCast/RayCastTopRight
@onready var ray_cast_top_left: RayCast2D = $RayCast/RayCastTopLeft

@onready var attack_timer: Timer = $AttackTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var MAX_HEALTH: int = 20

enum STATE {IDLE, ATTACK, RUN, DEAD}

const DAMAGE_POINT: int = 2
const KNOCKBACKVALUE: float = 30.0
const axisDir: Array[int] = [1, -1]

var SPEED = 40.0
var state: STATE = STATE.IDLE
var start_direction: int = axisDir[randi() % 2]
var parolePath: bool = true
var player: Player = null
var attackDistanceLeft: float = 31.0
var attackDistanceRight: float = 12.0
var hitCoolDownFinished: bool = false

var isDead: bool = false
var friction: float = 40.0
var acceleration: float = 50.0
var dir: float = 1.0
var health: float

func scaleHealth(h: float) -> float:
	return (h / MAX_HEALTH) * 100
	
func getGravity() -> float:
	return JUMP_GRAVITY if velocity.y < 0.0 else FALL_GRAVITY

func apply_damage(damagePoint: int) -> void:
	if isDead:
		return 
	animation_player.play("Hit")
	health  = max(health - damagePoint, 0)
	if health <= 0:
		animation_player.play("Dead")
		await get_tree().create_timer(0.6).timeout

		handleEnemyDead()
		
func knockBack() -> void:
	global_position.x += KNOCKBACKVALUE  * dir
	
func emitHitSignal() -> void:
	SignalManager.emit_signal("body_hit")
	
func handleEnemyDead() -> void:
	player = null
	isDead = true
	state = STATE.DEAD
	rotation_degrees = 0.0
	animated_sprite_2d.play("Dead 1")
	
	var power_up: PowerUP = HEALTH.instantiate()
	power_up.global_position = self.global_position
	get_tree().current_scene.add_child(power_up)

	animated_sprite_2d.material.set_shader_parameter("active", false)
	SignalManager.emit_signal("enemy_dead", self.name)
	
func handleMoveAndAvoidObstacles()-> void:
	velocity.x = start_direction * SPEED
	if not ray_cast_left_ground.is_colliding() or ray_cast_left.is_colliding() or ray_cast_top_left.is_colliding():
		start_direction = 1
		animated_sprite_2d.flip_h = false
		
	elif not ray_cast_right_ground.is_colliding() or ray_cast_right.is_colliding() or ray_cast_top_right.is_colliding():
		start_direction = -1
		animated_sprite_2d.flip_h = true
		
func handlestate() -> void:
	if state == STATE.ATTACK:
		animated_sprite_2d.play("Attack 1")
		return 
		
	match state:
		STATE.RUN:
			animated_sprite_2d.play("Move")
		STATE.IDLE:
			animated_sprite_2d.play("Walk")
			
func handleEnemyJump() -> void:
	velocity.y = JUMP_VELOCITY
	
func change_direction_of_sprite_animation(dir_x: float) -> void:
	if dir_x > 0.0:
		animated_sprite_2d.flip_h = false
	elif dir_x < 0.0:
		animated_sprite_2d.flip_h = true
	
func detect_obstacle_while_following_player() -> void:
	if ray_cast_left.is_colliding() or ray_cast_right.is_colliding():
		for coll in [ray_cast_left, ray_cast_right]:
			var body = coll.get_collider()
			if not body:
				continue
			if (body is TileMapLayer and is_on_wall()) or (body is EnemyBase and body.state == body.STATE.DEAD): # Tilemap base layer
				handleEnemyJump()
	else:
		state = STATE.RUN
	
func handleFollowPlayerLogic() -> void:
	if not player:
		return 
		
	if player.state == player.STATE.DEAD:
		parolePath = true
		state = STATE.IDLE
		return 
		
	_attack_player()


func _ready() -> void:
	health = MAX_HEALTH
	animated_sprite_2d.flip_h = true if start_direction != 1 else false
	
func _physics_process(delta: float) -> void:		
	if state == STATE.DEAD:
		apply_gravity(delta)
		move_and_slide()
		return
		
	if parolePath:
		handleMoveAndAvoidObstacles()
	else:
		handleFollowPlayerLogic()
	
		
	apply_gravity(delta)
	handle_input()
	handlestate()
	move_and_slide()
	
func handle_input() -> void:
	# Add the gravity.
	var axis: float = Input.get_axis("Left", "Right")
	if axis != 0:
		dir = axis
	
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += getGravity() * delta

func _on_detect_player_area_body_entered(body: Node2D) -> void:
	if state != STATE.DEAD and body is Player:
		player = body
		parolePath = false

func _attack_player() -> void:
	var angle: float = atan2(player.global_position.y - global_position.y, player.global_position.x - global_position.x)
	var distance: float = player.global_position.distance_to(global_position)
	var dir_x: float = round(cos(angle))
	
	if distance >= 200.0:
		Variables._launch(self, 400, Vector2(dir_x, 1))

	var is_player_to_the_left: bool = global_position.x > player.global_position.x
	var is_player_to_the_right: bool = global_position.x < player.global_position.x

	# If player is within attack range, trigger attack animationa
	if (is_player_to_the_left and distance <= attackDistanceLeft) or \
		(is_player_to_the_right and distance <= attackDistanceRight):
		state = STATE.ATTACK
		animated_sprite_2d.play("Attack 1")  # Start attack animation
	else:
		state = STATE.RUN
		velocity.x = move_toward(velocity.x, dir_x * SPEED, acceleration)
	
	change_direction_of_sprite_animation(dir_x)
	detect_obstacle_while_following_player()
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation in ["Attack 1", "Attack 2"]:
		var distance: float = player.global_position.distance_to(global_position)
		var is_player_to_the_left: bool = global_position.x > player.global_position.x
		var is_player_to_the_right: bool = global_position.x < player.global_position.x

		# Apply damage **only** if the player is still within attack range
		if (is_player_to_the_left and distance <= attackDistanceLeft) or \
			(is_player_to_the_right and distance <= attackDistanceRight):
			print("Attack landed at distance:", distance)
			player.applyHitDamage(self)
		# Reset to default movement behavior
		state = STATE.RUN
