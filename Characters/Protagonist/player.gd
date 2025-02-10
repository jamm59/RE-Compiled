extends CharacterBody2D

enum PLAYER_STATE {IDLE, JUMP, DASH, DASH_ATTACK, FALL, LAND, ATTACK, MOVING_LEFT, MOVING_RIGHT}


#@onready var hurt_box: CollisionShape2D = $HurtBox
#@onready var attack_timer: Timer = $AttackTimer
#@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
#@onready var dash_particle: GPUParticles2D = $ParticleParentNode/DashParticle
#@onready var particle_parent_node: Node2D = $ParticleParentNode

@export_category("Jump Settings")
@export var jump_height : float = 40
@export var jump_time_to_peak : float = 0.3
@export var jump_time_to_descent : float = 0.3


@onready var JUMP_VELOCITY : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var JUMP_GRAVITY : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var FALL_GRAVITY : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
@onready var FALL_GRAVITY_TEMP = FALL_GRAVITY

# WEAPON



signal cameraShake

var jump_count: int = 2
var PlayerDirection: int = 1
var playerDirection: int = 0
const DASH_MULTIPLIER: int = 2
const SPEED: float = 150.0
var wasOnFloor: bool = false
var isAttacking: bool = false
var isWallSliding: bool = false
var friction: float = 40
var acceleration: float = 50
var spriteInitialPosition: float
var previousDirection: int = 1

var currentPlayerState: PLAYER_STATE = PLAYER_STATE.IDLE

func getGravity() -> float:
	return JUMP_GRAVITY if velocity.y < 0.0 else FALL_GRAVITY
	#
#func ghosting(ghostSprite: Sprite2D, time: float) -> void:
	#var tweenFade = get_tree().create_tween()
	#tweenFade.tween_property(ghostSprite, "modulate", Color(1, 1, 1, 0), time )
	#await tweenFade.finished
	#ghostSprite.queue_free()
	#
#func handlePlayerDashAnimation() -> void:
	#dash_particle.emitting = true

	#ghosting(ghostSprite, time)

	
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
	if Input.is_action_just_pressed("Attack"):
		currentPlayerState = PLAYER_STATE.ATTACK
	if Input.is_action_pressed("Left"):
		currentPlayerState = PLAYER_STATE.MOVING_LEFT
		if previousDirection != -1:
			previousDirection = -1
			scale.x = -1 
		else: 
			scale.x = 1
	elif Input.is_action_pressed("Right"):
		currentPlayerState = PLAYER_STATE.MOVING_RIGHT
		if previousDirection != 1:
			previousDirection = 1
			scale.x = -1 
		else:
			scale.x = 1
	if Input.is_action_pressed("Dash"): # DASH IS INDEPENDENT OF OTHER EVENTS
		currentPlayerState = PLAYER_STATE.DASH
	wasOnFloor = is_on_floor()
	
	
		
func handleAnimationStateUpdate() -> void:
	match currentPlayerState:
		PLAYER_STATE.JUMP:
			#animated_sprite_2d.play("Jump")
			velocity.y = JUMP_VELOCITY
		#PLAYER_STATE.FALL:
			#animated_sprite_2d.play("Fall")
		#PLAYER_STATE.LAND:
			#animated_sprite_2d.play("Land")
		PLAYER_STATE.MOVING_RIGHT:
			animated_sprite_2d.play("Run")
			velocity.x = move_toward(velocity.x, 1 * SPEED, acceleration)
		PLAYER_STATE.MOVING_LEFT:
			animated_sprite_2d.play("Run")
			velocity.x = move_toward(velocity.x, -1 * SPEED, acceleration)

			
			
				

		PLAYER_STATE.DASH:
			#audio_player.pitch_scale = randf_range(0.5, 0.8)
			#audio_player.playing = true
			#handlePlayerDashAnimation()
			#velocity.x = playerDirection * SPEED * DASH_MULTIPLIER
			pass
		
		PLAYER_STATE.IDLE:
			if not isAttacking:
				animated_sprite_2d.play("Idle")
			velocity.x = move_toward(velocity.x, 0, friction)
		
	#if currentPlayerState != PLAYER_STATE.DASH:
		#dash_particle.emitting = false
			
func handleWeaponPosition() -> void:
	pass
	
	
func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	handleInput(delta)
	handleAnimationStateUpdate()
	handleWeaponPosition()
	handleJumpInput(delta)
	move_and_slide()
