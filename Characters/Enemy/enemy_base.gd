extends CharacterBody2D
class_name EnemyBase


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
var followPath: bool = true
var player: Player = null


var health: float
var dir: float = 1.0
var isDead: bool = false


func getGravity() -> float:
	return JUMP_GRAVITY if velocity.y < 0.0 else FALL_GRAVITY

func apply_damage(damagePoint: int) -> void:
	if isDead:
		return 
	animation_player.play("Hit")
	health  = max(health - damagePoint, 0)
	if health <= 0:
		animation_player.play("Dead")
		handleEnemyDead()
		
func knockBack() -> void:
	position.x += KNOCKBACKVALUE  * dir
	
func emitHitSignal() -> void:
	SignalManager.emit_signal("body_hit")
	
func handleEnemyDead() -> void:
	player = null
	isDead = true
	state = STATE.DEAD
	rotation_degrees = 0.0
	animated_sprite_2d.play("Dead 1")
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
	match state:
		STATE.ATTACK:
			animated_sprite_2d.play("Attack 1")
		STATE.RUN:
			animated_sprite_2d.play("Move")
		STATE.IDLE:
			animated_sprite_2d.play("Walk")
			
func handleEnemyJump() -> void:
	velocity.y = JUMP_VELOCITY
	
func handleFollowPlayerLogic() -> void:
	if player != null:
		if player.state == player.STATE.DEAD:
			followPath = true
			state = STATE.IDLE
			return 
		var player_position = player.position
		var angle_between_enemy_and_player = atan2(player_position.y - position.y, player_position.x - position.x)
		var dir_x = round(cos(angle_between_enemy_and_player))
		velocity.x = dir_x * SPEED
		
		if dir_x == 1:
			animated_sprite_2d.flip_h = false
		elif dir_x == -1:
			animated_sprite_2d.flip_h = true
			
		if ray_cast_left.is_colliding() or ray_cast_right.is_colliding():
			for coll in [ray_cast_left, ray_cast_right]:
				var body = coll.get_collider()
				if not body:
					continue
				if (body is TileMapLayer and is_on_wall()) or (body is EnemyBase and body.state == body.STATE.DEAD): # Tilemap base layer
					handleEnemyJump()
		else:
			state = STATE.RUN
				
func _ready() -> void:
	health = MAX_HEALTH
	animated_sprite_2d.flip_h = true if start_direction != 1 else false
	
func _physics_process(delta: float) -> void:		
	if state == STATE.DEAD:
		apply_gravity(delta)
		move_and_slide()
		return
		
	if state == STATE.ATTACK:
		return 
		
	if followPath:
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
	if not isDead and (not player and body is Player):
		player = body
		followPath = false


func _on_health_box_component_body_entered(body: Node2D) -> void:
	if not isDead and body is Player:
		if body.state == body.STATE.DEAD:
			followPath = true
			state = STATE.IDLE
		else:
			attack_timer.start()
			state = STATE.ATTACK
			animated_sprite_2d.play("Attack 1")
		
func _on_attack_timer_timeout() -> void:
	if player:
		var distance: float = player.global_position.distance_to(global_position)
		if distance <= 29.0:
			player.applyHitDamage(self)
		attack_timer.stop()


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation in ["Attack 1", "Attack 2"]:
		state = STATE.RUN
		
