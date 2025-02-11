extends CharacterBody2D


@export_category("Jump Settings")
@export var jump_height : float = 40
@export var jump_time_to_peak : float = 0.3
@export var jump_time_to_descent : float = 0.3


@onready var JUMP_VELOCITY : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var JUMP_GRAVITY : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var FALL_GRAVITY : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
@onready var FALL_GRAVITY_TEMP = FALL_GRAVITY



@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left_ground: RayCast2D = $RayCastLeftGround
@onready var ray_cast_right_ground: RayCast2D = $RayCastRightGround
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

enum ENEMY_STATE {IDLE, ATTACK, RUN}

const SPEED = 50.0
#const JUMP_VELOCITY = -400.0
const axisDir: Array[int] = [1, -1]
var enemyState: ENEMY_STATE = ENEMY_STATE.IDLE
var direction: int = axisDir[randi() % 2]



var followPath = true
var followPlayer = false
var PlayerReference: CharacterBody2D = null


func getGravity() -> float:
	return JUMP_GRAVITY if velocity.y < 0.0 else FALL_GRAVITY
	
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
		_:
			animated_sprite_2d.play("Walk")
			
			
func handleEnemyJump() -> void:
	velocity.y = JUMP_VELOCITY
	
func handleFollowPlayerLogic() -> void:
	
	if PlayerReference != null:
		var player_position = PlayerReference.position
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
			if body:
				if body.name == "Base" and is_on_wall(): # Tilemap base layer
					handleEnemyJump()
				if body.name == "Player":
					enemyState = ENEMY_STATE.ATTACK
	else:
		enemyState = ENEMY_STATE.RUN
					
func _ready() -> void:
	if direction == 1:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += getGravity() * delta
		
	if followPath:
		handleMoveAndAvoidObstacles()
		
	else:
		# follow player
		handleFollowPlayerLogic()
		
	handleEnemyState()
	move_and_slide()

func _on_detect_player_area_body_entered(body: CharacterBody2D) -> void:
	if body.name == "Player":
		PlayerReference = body
		followPath = false
