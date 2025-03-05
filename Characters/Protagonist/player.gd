extends CharacterBody2D
class_name Player

enum PLAYER_STATE {IDLE, JUMP, DASH, DASH_ATTACK, FALL, LAND, LIGHT_ATTACK, HEAVY_ATTACK, MOVING_LEFT, MOVING_RIGHT, DEAD}


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var top_animated_sprite_2d: AnimatedSprite2D = $TopAnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_box: CollisionShape2D = $AttackBoxComponent/AttackBox
@onready var dash_particle: GPUParticles2D = $GPUParticles2D

@export_category("Jump Settings")
@export var jump_height : float = 50
@export var jump_time_to_peak : float = 0.3
@export var jump_time_to_descent : float = 0.3

@export_category("Player Health")
@export var MAX_HEALTH: int = 20

@export_category("Other Settings")
@export var can_use_controls: bool = false

@onready var JUMP_VELOCITY : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var JUMP_GRAVITY : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var FALL_GRAVITY : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
@onready var WALL_FALL_GRAVITY: float = JUMP_VELOCITY / 3

# Constants
const DASH_MULTIPLIER: int = 2
const SPEED: float = 180.0
const KNOCKBACKVALUE: int = 30
const DAMAGE_POINT: int = 3
const WALL_PUSHBACK: int = 200

var toggle_gravity: bool =  false

var isDead: bool = false
var wasOnFloor: bool = false
var isWallSliding: bool = false

var friction: float = 40.0
var acceleration: float = 50.0
var spriteInitialPosition: float = 0.0
var initialScaleX: float = 0.0

var jump_count: int = 2
var previousDirection: int = 1
var health: int = 0


var currentPlayerState: PLAYER_STATE = PLAYER_STATE.IDLE

func getGravity() -> float:
	if isWallSliding:
		return WALL_FALL_GRAVITY
	return JUMP_GRAVITY if velocity.y < 0.0 else FALL_GRAVITY

	
func handleJumpInput(delta: float) -> void:
	if not toggle_gravity:
		if not is_on_floor():
			velocity.y += getGravity() * delta
		else:
			jump_count = 2
			
	if currentPlayerState == PLAYER_STATE.DEAD:
		return 
		
	if Input.is_action_just_pressed("Jump"):
		if jump_count > 0 or is_on_floor():
			currentPlayerState = PLAYER_STATE.JUMP
			velocity.y = JUMP_VELOCITY
			jump_count -= 1
		
		if is_on_wall() and Input.is_action_pressed("Right"):
			velocity.y = JUMP_VELOCITY
			velocity.x = -WALL_PUSHBACK
		if is_on_wall() and Input.is_action_pressed("Left"):
			velocity.y = JUMP_VELOCITY
			velocity.x = WALL_PUSHBACK
	
	if not is_on_floor() and velocity.y > 0:
		currentPlayerState = PLAYER_STATE.FALL
	
	if is_on_floor() and not wasOnFloor:
		currentPlayerState = PLAYER_STATE.LAND
		

func handleInput(delta: float) -> void:

	var dir = Input.get_axis("Left", "Right")
	
	if currentPlayerState not in [PLAYER_STATE.DEAD, PLAYER_STATE.LIGHT_ATTACK, PLAYER_STATE.HEAVY_ATTACK] and (dir == 0 and velocity.y < 1):
		currentPlayerState = PLAYER_STATE.IDLE
		
	if not can_use_controls:
		return 
		
	if Input.is_action_pressed("Light_A"):
		currentPlayerState = PLAYER_STATE.LIGHT_ATTACK
		attack_box.disabled = false
		
	elif Input.is_action_pressed("Heavy_A"):
		currentPlayerState = PLAYER_STATE.HEAVY_ATTACK
		attack_box.disabled = false
		
	else:
		attack_box.disabled = true
		
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
	var animationName: String = ""
	var topAnimationName: String = "Idle"
	match currentPlayerState:
		PLAYER_STATE.DEAD:
			animationName = "Dead"
		PLAYER_STATE.JUMP:
			animationName = "Jump"
		PLAYER_STATE.FALL:
			animationName = "Fall"
		PLAYER_STATE.LAND:
			animationName = "Land"
		PLAYER_STATE.MOVING_RIGHT:
			animationName = "Run"
			velocity.x = move_toward(velocity.x, 1 * SPEED, acceleration)
		PLAYER_STATE.MOVING_LEFT:
			animationName = "Run"
			velocity.x = move_toward(velocity.x, -1 * SPEED, acceleration)
		PLAYER_STATE.LIGHT_ATTACK:
			animationName = "Light"
		PLAYER_STATE.HEAVY_ATTACK:
			animationName = "Heavy"
			topAnimationName = "Heavy"
		PLAYER_STATE.DASH:
			var axis: int = Input.get_axis("Left", "Right")
			if axis == 1:
				dash_particle.material.set_shader_parameter("facing_left", false)
			elif axis == -1:
				dash_particle.material.set_shader_parameter("facing_left", true)
			velocity.x = axis * SPEED * DASH_MULTIPLIER
			dash_particle.emitting = true
		PLAYER_STATE.IDLE:
			animationName = "Idle"
			velocity.x = move_toward(velocity.x, 0, friction)
			
	animated_sprite_2d.play(animationName)
	top_animated_sprite_2d.play(topAnimationName)
	
	if currentPlayerState != PLAYER_STATE.DASH:
		dash_particle.emitting = false
			
func applyHitDamage(enemy: EnemyBase):
	if currentPlayerState == PLAYER_STATE.DEAD:
		return 
	knockBack(enemy)
	health = max(health - enemy.DAMAGE_POINT, 0)
	animation_player.play("Hit")

	if health <= 0:
		animated_sprite_2d.play("Dead")
		currentPlayerState = PLAYER_STATE.DEAD
		
func knockBack(enemy: EnemyBase) -> void:
	if enemy.position.x > self.position.x:
		position.x -= KNOCKBACKVALUE
	else:
		position.x += KNOCKBACKVALUE
	
func _ready() -> void:
	initialScaleX = self.scale.x
	health = MAX_HEALTH
	
func _physics_process(delta: float) -> void:
	handleJumpInput(delta)
	
	if currentPlayerState in [PLAYER_STATE.DEAD, PLAYER_STATE.LIGHT_ATTACK, PLAYER_STATE.HEAVY_ATTACK]:
		return
	
	handleInput(delta)
	handleAnimationStateUpdate()
	move_and_slide()


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation in ["Light", "Heavy"]:
		currentPlayerState = PLAYER_STATE.IDLE


func _on_attack_box_component_body_entered(body: Node2D) -> void:
		if body is EnemyBase:
			body.apply_damage(DAMAGE_POINT)
