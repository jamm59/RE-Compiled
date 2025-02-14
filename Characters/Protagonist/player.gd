extends CharacterBody2D

enum PLAYER_STATE {IDLE, JUMP, DASH, DASH_ATTACK, FALL, LAND, ATTACK, MOVING_LEFT, MOVING_RIGHT}


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export_category("Jump Settings")
@export var jump_height : float = 40
@export var jump_time_to_peak : float = 0.3
@export var jump_time_to_descent : float = 0.3


@onready var JUMP_VELOCITY : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var JUMP_GRAVITY : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var FALL_GRAVITY : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
@onready var FALL_GRAVITY_TEMP = FALL_GRAVITY

# WEAPON



#signal cameraShake
#signal attackAnimation

var jump_count: int = 2
const DASH_MULTIPLIER: int = 3
const SPEED: float = 150.0
var wasOnFloor: bool = false
var isAttacking: bool = false
var isWallSliding: bool = false
var friction: float = 40
var acceleration: float = 50
var spriteInitialPosition: float
var previousDirection: int = 1
var initialScaleX: float = scale.x


var currentPlayerState: PLAYER_STATE = PLAYER_STATE.IDLE

func getGravity() -> float:
	return JUMP_GRAVITY if velocity.y < 0.0 else FALL_GRAVITY
	
func handleJumpInput(delta: float) -> void:
	if not is_on_floor():
		velocity.y += getGravity() * delta
	else:
		jump_count = 2
		
	if Input.is_action_just_pressed("Jump"):
		if jump_count == 1 or is_on_floor() and jump_count > 0:
			currentPlayerState = PLAYER_STATE.JUMP
			velocity.y = JUMP_VELOCITY
			jump_count -= 1
	
	if not is_on_floor() and velocity.y > 0:
		currentPlayerState = PLAYER_STATE.FALL
	
	if is_on_floor() and not wasOnFloor:
		currentPlayerState = PLAYER_STATE.LAND
		

func handleInput(delta: float) -> void:

	var dir = Input.get_axis("Left", "Right")
	
	if dir == 0 and velocity.y < 1:
		currentPlayerState = PLAYER_STATE.IDLE
		
	if Input.is_action_pressed("Attack"):
		currentPlayerState = PLAYER_STATE.ATTACK
		isAttacking = true
		#animated_sprite_2d.play("Attack")
		
	if Input.is_action_pressed("Left"):
		currentPlayerState = PLAYER_STATE.MOVING_LEFT
		if previousDirection != -1:
			previousDirection = -1
			scale.x = -1 * initialScaleX 
		else: 
			scale.x = 1 * initialScaleX
			
	elif Input.is_action_pressed("Right"):
		currentPlayerState = PLAYER_STATE.MOVING_RIGHT
		if previousDirection != 1:
			previousDirection = 1
			scale.x = -1 * initialScaleX 
		else:
			scale.x = 1 * initialScaleX
	if Input.is_action_pressed("Dash"): # DASH IS INDEPENDENT OF OTHER EVENTS
		currentPlayerState = PLAYER_STATE.DASH
		
	wasOnFloor = is_on_floor()
	
	
		
func handleAnimationStateUpdate() -> void:
	
	match currentPlayerState:
		PLAYER_STATE.JUMP:
			animated_sprite_2d.play("Jump")
		PLAYER_STATE.FALL:
			animated_sprite_2d.play("Fall")
		PLAYER_STATE.LAND:
			animated_sprite_2d.play("Land")
		PLAYER_STATE.MOVING_RIGHT:
			animated_sprite_2d.play("Run")
			velocity.x = move_toward(velocity.x, 1 * SPEED, acceleration)
		PLAYER_STATE.MOVING_LEFT:
			animated_sprite_2d.play("Run")
			velocity.x = move_toward(velocity.x, -1 * SPEED, acceleration)
		PLAYER_STATE.ATTACK:
			animated_sprite_2d.play("Attack")
		PLAYER_STATE.DASH:
			var axis: int = Input.get_axis("Left", "Right")
			velocity.x = axis * SPEED * DASH_MULTIPLIER
		PLAYER_STATE.IDLE:
			animated_sprite_2d.play("Idle")
			velocity.x = move_toward(velocity.x, 0, friction)
		
	#if currentPlayerState != PLAYER_STATE.DASH:
		#dash_particle.emitting = false
			
			
func _ready() -> void:
	initialScaleX = self.scale.x
	
func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	handleInput(delta)
	handleAnimationStateUpdate()
	handleJumpInput(delta)
	move_and_slide()
