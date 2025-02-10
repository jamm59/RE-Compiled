extends CharacterBody2D

@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left_ground: RayCast2D = $RayCastLeftGround
@onready var ray_cast_right_ground: RayCast2D = $RayCastRightGround
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

enum ENEMY_STATE {IDLE, MOVING_LEFT, MOVING_RIGHT}

const SPEED = 50.0
const JUMP_VELOCITY = -400.0
const axisDir: Array[int] = [1, -1]
var enemyState: ENEMY_STATE = ENEMY_STATE.IDLE
var direction: int = axisDir[randi() % 2]


func _ready() -> void:
	if direction == 1:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false
	

func handleAvoidObstacles()-> void:
	if not ray_cast_left_ground.is_colliding() or ray_cast_left.is_colliding():
		direction = 1
		animated_sprite_2d.flip_h = true
		
	elif not ray_cast_right_ground.is_colliding() or ray_cast_right.is_colliding():
		direction = -1
		animated_sprite_2d.flip_h = false
	
		
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	velocity.x = direction * SPEED
	
	handleAvoidObstacles()
	#handleStateMovement()
		
	

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
