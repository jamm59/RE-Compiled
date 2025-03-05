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
#
#@onready var monster_animated_sprite: AnimatedSprite2D = $MonsterAnimatedSprite
#@onready var ghoul_animated_sprite: AnimatedSprite2D = $GhoulAnimatedSprite
#@onready var droid_animated_sprite: AnimatedSprite2D = $DroidAnimatedSprite
#@onready var mecha_animated_sprite: AnimatedSprite2D = $MechaAnimatedSprite
#@onready var spitter_animated_sprite: AnimatedSprite2D = $SpitterAnimatedSprite
#@onready var summoner_animated_sprite: AnimatedSprite2D = $SummonerAnimatedSprite


@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left_ground: RayCast2D = $RayCastLeftGround
@onready var ray_cast_right_ground: RayCast2D = $RayCastRightGround
@onready var attack_timer: Timer = $AttackTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var MAX_HEALTH: int = 20

enum ENEMY_STATE {IDLE, ATTACK, RUN, DEAD}

const DAMAGE_POINT: int = 2
const KNOCKBACKVALUE: int = 30
var SPEED = 40.0
#const JUMP_VELOCITY = -400.0
const axisDir: Array[int] = [1, -1]
var enemyState: ENEMY_STATE = ENEMY_STATE.IDLE
var direction: int = axisDir[randi() % 2]
var followPath: bool = true
var player: Player = null


var health: float
var dir: int = 1
var isDead: bool = false


func getGravity() -> float:
	return JUMP_GRAVITY if velocity.y < 0.0 else FALL_GRAVITY

func apply_damage(damagePoint: int) -> void:
	if isDead:
		return 
	health  = max(health - damagePoint, 0)
	animation_player.play("Hit")
	
	if health <= 0:
		animation_player.play("Dead")
		handleEnemyDead()
		
func knockBack() -> void:
	position.x += KNOCKBACKVALUE  * dir
	
func emitHitSignal() -> void:
	SignalManager.emit_signal("enemy_hit")
	
func handleEnemyDead() -> void:
	enemyState = ENEMY_STATE.DEAD
	animated_sprite_2d.play("Dead 1")
	player = null
	isDead = true
	
func handleMoveAndAvoidObstacles()-> void:
	velocity.x = direction * SPEED
	if not ray_cast_left_ground.is_colliding() or ray_cast_left.is_colliding():
		direction = 1
		animated_sprite_2d.flip_h = true
		
	elif not ray_cast_right_ground.is_colliding() or ray_cast_right.is_colliding():
		direction = -1
		animated_sprite_2d.flip_h = false

func handleEnemyState() -> void:
	match enemyState:
		ENEMY_STATE.ATTACK:
			animated_sprite_2d.play("Attack 1")
		ENEMY_STATE.RUN:
			animated_sprite_2d.play("Run")
		ENEMY_STATE.IDLE:
			animated_sprite_2d.play("Walk")
			
func handleEnemyJump() -> void:
	velocity.y = JUMP_VELOCITY
	
func handleFollowPlayerLogic() -> void:
	if player != null:
		var player_position = player.position
		var angle_between_enemy_and_player = atan2(player_position.y - position.y, player_position.x - position.x)
		var dir_x = round(cos(angle_between_enemy_and_player))
		if dir_x == 1:
			animated_sprite_2d.flip_h = true
		elif dir_x == -1:
			animated_sprite_2d.flip_h = false
		velocity.x = dir_x * SPEED
		if ray_cast_left.is_colliding() or ray_cast_right.is_colliding():
			for coll in [ray_cast_left, ray_cast_right]:
				var body = coll.get_collider()
				if not body:
					continue
				if (body is TileMapLayer and is_on_wall()) or (body is EnemyBase): # Tilemap base layer
					handleEnemyJump()
		else:
			enemyState = ENEMY_STATE.RUN
				
				
	
func _ready() -> void:
	health = MAX_HEALTH
	if direction == 1:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	var axis: int = Input.get_axis("Left", "Right")
	if axis in [1, -1]:
		dir = axis
		
	if not is_on_floor():
		velocity.y += getGravity() * delta
		
	if enemyState == ENEMY_STATE.DEAD:
		return
		
	if enemyState == ENEMY_STATE.ATTACK:
		return 
		
	if followPath:
		handleMoveAndAvoidObstacles()
	else:
		handleFollowPlayerLogic()
	
	handleEnemyState()
	move_and_slide()

func _on_detect_player_area_body_entered(body: Node2D) -> void:
	if not isDead and (not player and body is Player):
		player = body
		followPath = false

func _on_health_box_component_body_entered(body: Node2D) -> void:
	if not isDead and body is Player:
		if body.currentPlayerState == body.PLAYER_STATE.DEAD:
			followPath = true
			enemyState = ENEMY_STATE.IDLE
		else:
			attack_timer.start()
			enemyState = ENEMY_STATE.ATTACK
			animated_sprite_2d.play("Attack 1")
			

func _on_attack_timer_timeout() -> void:
	if player:
		var distance: Vector2 = abs(player.position - position)
		var x: float = distance[0]
		if x <= 29.0:
			player.applyHitDamage(self)
		attack_timer.stop()


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation in ["Attack 1", "Attack 2"]:
		enemyState = ENEMY_STATE.RUN
		
