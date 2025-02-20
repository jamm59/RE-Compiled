extends CharacterBody2D
class_name Player

enum PLAYER_STATE {IDLE, JUMP, DASH, DASH_ATTACK, FALL, LAND, ATTACK, MOVING_LEFT, MOVING_RIGHT, DEAD}


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_box: CollisionShape2D = $AttackBoxComponent/AttackBox

@export_category("Jump Settings")
@export var jump_height : float = 40
@export var jump_time_to_peak : float = 0.3
@export var jump_time_to_descent : float = 0.3

@export_category("Player Health")
@export var MAX_HEALTH: int = 20
@export var can_use_controls: bool = false

@onready var JUMP_VELOCITY : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var JUMP_GRAVITY : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var FALL_GRAVITY : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
@onready var FALL_GRAVITY_TEMP = FALL_GRAVITY

# Constants
const DASH_MULTIPLIER: int = 2
const SPEED: float = 160.0
const KNOCKBACKVALUE: int = 30
const DAMAGE_POINT: int = 3

#signal cameraShake
#signal attackAnimation

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
	
	if currentPlayerState not in [PLAYER_STATE.DEAD, PLAYER_STATE.ATTACK] and (dir == 0 and velocity.y < 1):
		currentPlayerState = PLAYER_STATE.IDLE
		
	if Input.is_action_pressed("Attack"):
		currentPlayerState = PLAYER_STATE.ATTACK
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
	
	match currentPlayerState:
		PLAYER_STATE.DEAD:
			animated_sprite_2d.play("Dead")
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
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	if currentPlayerState == PLAYER_STATE.DEAD:
		return 
		
	handleJumpInput(delta)
	if currentPlayerState == PLAYER_STATE.ATTACK:
		return
	
	#if can_use_controls:
	handleInput(delta)
	handleAnimationStateUpdate()
	move_and_slide()


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "Attack":
		currentPlayerState = PLAYER_STATE.IDLE


func _on_attack_box_component_body_entered(body: Node2D) -> void:
		if body is EnemyBase:
			body.apply_damage(DAMAGE_POINT)
