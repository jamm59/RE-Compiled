extends CharacterBody2D
class_name Player

enum PLAYER_STATE {IDLE, JUMP, DASH, ROLL, DASH_ATTACK, FALL, LAND, LIGHT_ATTACK, HEAVY_ATTACK, MOVING_LEFT, MOVING_RIGHT, DEAD}


@onready var hud: PlayerHUD = $HUD

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var dash_particle: GPUParticles2D = $GPUParticles2D
@onready var attack_box_right: CollisionShape2D = $AttackBoxComponent/AttackBoxRight
@onready var attack_box_left: CollisionShape2D = $AttackBoxComponent/AttackBoxLeft

@onready var white: AnimatedSprite2D = $AnimatedSprites/White
@onready var red: AnimatedSprite2D = $AnimatedSprites/Red
@onready var dark: AnimatedSprite2D = $AnimatedSprites/Dark
@onready var dead_aimation: AnimatedSprite2D = $DeadAimation


@export_category("Jump Settings")
@export var jump_height : float = 50
@export var jump_time_to_peak : float = 0.3
@export var jump_time_to_descent : float = 0.3

@export_category("Player Health")
@export var MAX_HEALTH: float = 20.0

@export_category("Other Settings")
@export var can_use_controls: bool = false
@export var previousAnimation: String = "Red"

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
const FALL_DISTANCE_THRESHOLD: int = 100

var toggle_gravity: bool =  false

var isDead: bool = false
var wasOnFloor: bool = false
var isWallSliding: bool = false
var canClimbLadder: bool = false

var friction: float = 40.0
var acceleration: float = 50.0
var spriteInitialPosition: float = 0.0
var initialScaleX: float = 0.0

var jump_count: int = 2
var previousDirection: float = 1.0
var health: float = 0.0
var stamina: float = 100.0
var statsInitDone: bool = false

var last_ground_y: float = 0
var currentPlayerState: PLAYER_STATE = PLAYER_STATE.IDLE

func _ready() -> void:
	updateAnimatedSprite(red if previousAnimation == "Red" else white, true, false, false)
	health = MAX_HEALTH
	tweenProgressBar(hud.health, scaleHealth(health), 1.0)
	tweenProgressBar(hud.stamina, stamina, 1.0)
	
func _physics_process(delta: float) -> void:
	if currentPlayerState == PLAYER_STATE.DEAD:
		return 
	handleJumpInput(delta)
	if currentPlayerState in [PLAYER_STATE.LIGHT_ATTACK, PLAYER_STATE.HEAVY_ATTACK]:
		return

	handleInput()
	handleAttackBoxVisibility()
	handleAnimationStateUpdate()
	move_and_slide()
	
	
func scaleHealth(health: float) -> float:
	return (health / MAX_HEALTH) * 100
	
func tweenProgressBar(progressBar: ProgressBar, value:float, time: float = 0.3) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(progressBar, "value", value, time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	statsInitDone = true
	
func getGravity() -> float:
	if isWallSliding:
		return WALL_FALL_GRAVITY
	return JUMP_GRAVITY if velocity.y < 0.0 else FALL_GRAVITY

func handleJumpInput(delta: float) -> void:
	if is_on_ceiling() and currentPlayerState == PLAYER_STATE.FALL: #Checking if we stuck between a ceiling and floor
		position.x += previousDirection * 10
		
	if not toggle_gravity:
		if not is_on_floor():
			velocity.y += getGravity() * delta
		else:
			jump_count = 2
			
		if can_use_controls and Input.is_action_just_pressed("Jump"):
			if jump_count > 0 or is_on_floor():
				currentPlayerState = PLAYER_STATE.JUMP
				animated_sprite_2d.play("Jump")
				velocity.y = JUMP_VELOCITY
				jump_count -= 1
	else:
		currentPlayerState = PLAYER_STATE.JUMP
		velocity.y = JUMP_VELOCITY + 50
		animated_sprite_2d.play("Jump")
		
	if canClimbLadder and Input.is_action_pressed("Interact"):
		toggle_gravity = true
		can_use_controls = false
		
	if currentPlayerState == PLAYER_STATE.DEAD:
		return 
	
	if not is_on_floor() and velocity.y > 0:
		currentPlayerState = PLAYER_STATE.FALL
	
	if is_on_floor() and not wasOnFloor:
		currentPlayerState = PLAYER_STATE.LAND
		if global_position.y - last_ground_y > FALL_DISTANCE_THRESHOLD:
			SignalManager.emit_signal("large_fall_detected")
		last_ground_y = global_position.y  
		
func handleAttackBoxVisibility() -> void:
	if currentPlayerState in [PLAYER_STATE.LIGHT_ATTACK, PLAYER_STATE.HEAVY_ATTACK]:
		if previousDirection < 0:
			attack_box_left.disabled = false
			attack_box_right.disabled = true
		elif previousDirection > 0:
			attack_box_left.disabled = true
			attack_box_right.disabled = false
	else:
		attack_box_left.disabled = true
		attack_box_right.disabled = true

func handleInput() -> void:
	var dir = Input.get_axis("Left", "Right")
	
	if currentPlayerState not in [PLAYER_STATE.DEAD, PLAYER_STATE.LIGHT_ATTACK, PLAYER_STATE.HEAVY_ATTACK] and (dir == 0 and velocity.y == 0.0):
		currentPlayerState = PLAYER_STATE.IDLE
		
	if not can_use_controls:
		return 
		
	if Input.is_action_pressed("Light_A"):
		currentPlayerState = PLAYER_STATE.LIGHT_ATTACK
	elif Input.is_action_pressed("Heavy_A"):
		currentPlayerState = PLAYER_STATE.HEAVY_ATTACK

	if Input.is_action_pressed("Left"):
		currentPlayerState = PLAYER_STATE.MOVING_LEFT
		animated_sprite_2d.flip_h = true
			
	if Input.is_action_pressed("Right"):
		currentPlayerState = PLAYER_STATE.MOVING_RIGHT
		animated_sprite_2d.flip_h = false
			
	if Input.is_action_pressed("Dash"): # DASH IS INDEPENDENT OF OTHER EVENTS
		currentPlayerState = PLAYER_STATE.DASH
		
	if Input.is_action_pressed("Roll"):
		currentPlayerState = PLAYER_STATE.ROLL
		$HitBoxComponent.disabled = true
		$RollHitBoxComponent.disabled = false
	else:
		$HitBoxComponent.disabled = false
		$RollHitBoxComponent.disabled = true
		
	wasOnFloor = is_on_floor()
	previousDirection = dir if dir != 0 else previousDirection
		
func handleAnimationStateUpdate() -> void:
	var axis: float = Input.get_axis("Left", "Right")
	var animationName: String = ""
	
	if axis != 0.0:
		dash_particle.material.set_shader_parameter("facing_left", false if axis > 0 else true)
		
	match currentPlayerState:
		PLAYER_STATE.DEAD:
			animationName = "Dead"
		PLAYER_STATE.JUMP:
			animationName = "Jump"
		PLAYER_STATE.FALL:
			animationName = "Fall"
		PLAYER_STATE.MOVING_RIGHT, PLAYER_STATE.MOVING_LEFT:
			animationName = "Run" if velocity.y == 0.0 else ""
			velocity.x = move_toward(velocity.x, previousDirection * SPEED, acceleration)
		PLAYER_STATE.LIGHT_ATTACK:
			animationName = ["Light1", "Light2", "Light3"].pick_random()
		PLAYER_STATE.HEAVY_ATTACK:
			animationName = "Heavy"
		PLAYER_STATE.DASH:
			velocity.x = move_toward(velocity.x, previousDirection * SPEED * DASH_MULTIPLIER, acceleration)
			if velocity.y == 0.0:	
				dash_particle.emitting = true
				animationName = "Dash"
		PLAYER_STATE.ROLL:
			velocity.x = move_toward(velocity.x, previousDirection * SPEED * DASH_MULTIPLIER, acceleration)
			animationName = "Roll" if velocity.y == 0.0 else ""
		PLAYER_STATE.IDLE:
			animationName = "Idle"
			velocity.x = move_toward(velocity.x, 0, friction)
			
	animated_sprite_2d.play(animationName)
	
	
	if statsInitDone:
		var deductStaminaSpeed: float = 20
		var increaseStaminaSpeed: float = 40
		if animationName in ["Dash", "Roll"]:
			stamina = max(stamina - deductStaminaSpeed, 10)
		else:
			stamina = min(stamina + increaseStaminaSpeed, 100)
		tweenProgressBar(hud.stamina, stamina)
	
	if currentPlayerState != PLAYER_STATE.DASH:
		dash_particle.emitting = false
			
func applyHitDamage(body: Node2D):
	animation_player.play("Hit")
	SignalManager.emit_signal("body_hit")
	if currentPlayerState == PLAYER_STATE.DEAD:
		return 
	if body is EnemyBase:
		knockBack(body)
		health = max(health - body.DAMAGE_POINT, 0.0)
	if body is Laser:
		health = max(health - body.DAMAGE_POINT, 0.0)
	
	tweenProgressBar(hud.health, scaleHealth(health))
	
	if health <= 0.0:
		animated_sprite_2d.play("Dead")
		currentPlayerState = PLAYER_STATE.DEAD
		dead_aimation.visible = true
		dead_aimation.flip_h = animated_sprite_2d.flip_h
		
func knockBack(enemy: EnemyBase) -> void:
	if enemy.position.x > self.position.x:
		position.x -= KNOCKBACKVALUE
	else:
		position.x += KNOCKBACKVALUE
	
func updateAnimatedSprite(aSprite: AnimatedSprite2D, red_visible: bool, white_visible: bool, dark_visible: bool) -> void:
	var isFlipped: bool = animated_sprite_2d.flip_h
	aSprite.flip_h = isFlipped
	animated_sprite_2d = aSprite
	red.visible = red_visible
	white.visible = white_visible
	dark.visible = dark_visible
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation in ["Light1","Light2","Light3","AttackCombo", "Heavy", "Roll"]:
		currentPlayerState = PLAYER_STATE.IDLE
		
	if animated_sprite_2d.animation == "Heavy" and animated_sprite_2d.name in ["Red", "White"]:
		previousAnimation = animated_sprite_2d.name
		updateAnimatedSprite(dark, false, false, true)
	elif animated_sprite_2d.animation == "Heavy" and animated_sprite_2d.name == "Dark":
		if previousAnimation == "Red":
			updateAnimatedSprite(red, true, false, false)
		elif previousAnimation == "White":
			updateAnimatedSprite(white, false, true, false)
		
func _on_attack_box_component_body_entered(body: Node2D) -> void:
	if body is EnemyBase:
		body.apply_damage(DAMAGE_POINT)
			
func _on_ladder_area_body_entered(body: Node2D) -> void:
	if body is Player:
		canClimbLadder = true

func _on_ladder_area_body_exited(body: Node2D) -> void:
	if body is Player:
		canClimbLadder = false
		toggle_gravity = false
		can_use_controls = true
