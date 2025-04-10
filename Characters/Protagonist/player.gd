extends CharacterBody2D
class_name Player

enum STATE {IDLE, JUMP, DASH, ROLL, DASH_ATTACK, FALL, LAND, WALLSLIDE, POWERUP, LIGHT_ATTACK, HEAVY_ATTACK, MOVING_LEFT, MOVING_RIGHT, DEAD}

@onready var hud: PlayerHUD = $HUD

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var dash_particle: GPUParticles2D = $GPUParticles2D
@onready var attack_box_right: CollisionShape2D = $AttackBoxComponent/AttackBoxRight
@onready var attack_box_left: CollisionShape2D = $AttackBoxComponent/AttackBoxLeft

@onready var dead_aimation: AnimatedSprite2D = $DeadAimation
@onready var vfx: AnimatedSprite2D = $Vfx

@onready var short_range_terminal: ShortRangeTerminal = $Inventory/ShortRange
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $Node2D/AudioStreamPlayer2D

@onready var top_ray_cast_2d: RayCast2D = $RayCast/topRayCast2D
@onready var bottom_ray_cast_2d: RayCast2D = $RayCast/bottomRayCast2D
@onready var left_ray_cast_2d: RayCast2D = $RayCast/LeftRayCast2D
@onready var right_ray_cast_2d: RayCast2D = $RayCast/RightRayCast2D



@export_category("Jump Settings")
@export var jump_height : float = 50
@export var jump_time_to_peak : float = 0.3
@export var jump_time_to_descent : float = 0.3

@export_category("Player Health")
@export var MAX_HEALTH: float = 20.0

@export_category("Other Settings")
@export var can_use_controls: bool = false

@onready var JUMP_VELOCITY : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var JUMP_GRAVITY : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var FALL_GRAVITY : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
@onready var WALL_FALL_GRAVITY: float = FALL_GRAVITY / 10

const LAND_HEAVY = preload("res://Assets/Music/land_heavy.mp3")
const SLASH = preload("res://Assets/Music/slash.mp3")
const SWORD_HIT = preload("res://Assets/Music/sword-hit.mp3")
const LAND = preload("res://Assets/Music/land-new.mp3")
const STEP_NEW = preload("res://Assets/Music/step-new.mp3")
# Constants
const DASH_MULTIPLIER: float = 2.0
const ROLL_MULTIPLIER: float = 2.0
const SPEED: float = 180.0
const KNOCKBACKVALUE: float = 30
const DAMAGE_POINT: float = 3.0
const DAMAGE_POINT_HEAVY: float = 5.0
const WALL_PUSHBACK: float = 200.0
const FALL_DISTANCE_THRESHOLD: float = 100.0

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
var coins: int = 0
var stamina: float = 100.0
var statsInitDone: bool = false

var last_ground_y: float = 0
var state: STATE = STATE.IDLE

var emitShortRangeSignal: bool = false

var inventory: Array[String] = []

func _ready() -> void:
	health = MAX_HEALTH
	tweenProgressBar(hud.health, scaleHealth(health), 1.0)
	tweenProgressBar(hud.stamina, stamina, 1.0)
	
func _physics_process(delta: float) -> void:
	var sliding: bool = false
	
	if state == STATE.DEAD:
		velocity.x = move_toward(velocity.x, 0, friction)
		applyDeadFallGravity(delta)
		sliding = true
		move_and_slide()
		return 
		
	if state == STATE.ROLL:
		if is_on_floor():
			
			velocity.x = move_toward(velocity.x, previousDirection * SPEED * ROLL_MULTIPLIER, acceleration)
			for ray: RayCast2D in [left_ray_cast_2d, right_ray_cast_2d]:
				if not ray.is_colliding():
					continue
				var collider: Node2D = ray.get_collider()
				if collider is TileMapLayer:
					state = STATE.IDLE
					velocity.x = move_toward(velocity.x, 0.0, friction)

			if Input.is_action_just_pressed("Jump") and not top_ray_cast_2d.is_colliding() \
			or (top_ray_cast_2d.is_colliding() and top_ray_cast_2d.get_collider() is not TileMapLayer):
				state = STATE.JUMP
				velocity.x = move_toward(velocity.x, 0, friction)
				handleJumpInput(delta)
				return 
			
			if Input.is_action_pressed("Left"):
				state = STATE.MOVING_LEFT
				animated_sprite_2d.flip_h = true
				previousDirection = -1
					
			if Input.is_action_pressed("Right"):
				state = STATE.MOVING_RIGHT
				animated_sprite_2d.flip_h = false
				previousDirection = 1
				
			if Input.is_action_pressed("Light_A"):
				state = STATE.LIGHT_ATTACK
				play_sound(SLASH)
				handleAttackBoxVisibility()
				handleAnimationStateUpdate()
				
			elif Input.is_action_pressed("Heavy_A"):
				state = STATE.HEAVY_ATTACK
				play_sound(SLASH)
				handleAttackBoxVisibility()
				handleAnimationStateUpdate()
		
		else:
			state = STATE.IDLE
			velocity.x = move_toward(velocity.x, 0.0, friction)
			
		applyDeadFallGravity(delta)
		sliding = true
		move_and_slide()
		return
		
	if state in [STATE.LIGHT_ATTACK, STATE.HEAVY_ATTACK, STATE.POWERUP]:
		velocity.x = move_toward(velocity.x, 0, friction)
		applyDeadFallGravity(delta)
		sliding = true
		move_and_slide() 
		return

	handleJumpInput(delta)
	handleInput()
	handleAttackBoxVisibility()
	handleAnimationStateUpdate()
	if not sliding:
		move_and_slide()
	
	
func play_sound(source: AudioStreamMP3):
	audio_stream_player_2d.stream = source
	audio_stream_player_2d.play()
	
func update_coin() -> void:
	coins += 1
	
func _get_gravity() -> float:
	if state == STATE.ROLL:
		return 0.0
	return JUMP_GRAVITY if velocity.y < 0.0 else FALL_GRAVITY
	
func apply_power_up(POWER_UP_VALUE: float) -> void:
	health = min(MAX_HEALTH, health + POWER_UP_VALUE)
	tweenProgressBar(hud.health, scaleHealth(health))
	state = STATE.POWERUP
	animated_sprite_2d.play("PowerUP")

	
func applyDeadFallGravity(delta: float):
	if not is_on_floor():
		velocity.y += _get_gravity() * delta

func scaleHealth(health: float) -> float:
	return (health / MAX_HEALTH) * 100
	
func tweenProgressBar(progressBar: ProgressBar, value:float, time: float = 0.3) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(progressBar, "value", value, time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	statsInitDone = true
	
func handleJumpInput(delta: float) -> void:
	if not toggle_gravity:
		if not is_on_floor():
			velocity.y += _get_gravity() * delta
		else:
			jump_count = 2
			
		if (can_use_controls and not isWallSliding) and Input.is_action_just_pressed("Jump"):
			if (jump_count > 0 or is_on_floor()):
				jump_count -= 1
				state = STATE.JUMP
				velocity.y = JUMP_VELOCITY
				animated_sprite_2d.play("Jump")
	else:
		state = STATE.JUMP
		velocity.y = JUMP_VELOCITY + 50
		animated_sprite_2d.play("Jump")

	if not is_on_floor() and velocity.y > 0:
		state = STATE.FALL
		
	if is_on_floor() and not wasOnFloor:
		state = STATE.LAND
		if global_position.y - last_ground_y > FALL_DISTANCE_THRESHOLD:
			play_sound(LAND_HEAVY)
			SignalManager.emit_signal("large_fall_detected")
		else:
			play_sound(LAND)
		last_ground_y = global_position.y  
		
	if canClimbLadder and Input.is_action_pressed("Interact"):
		toggle_gravity = true
		can_use_controls = false
		
func handleAttackBoxVisibility() -> void:
	if state in [STATE.LIGHT_ATTACK, STATE.HEAVY_ATTACK]:
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
	
	if state not in [STATE.DEAD, STATE.LIGHT_ATTACK, STATE.HEAVY_ATTACK, STATE.POWERUP] and (dir == 0 and velocity.y == 0.0):
		state = STATE.IDLE
		
	if not can_use_controls:
		return 
	
	if bottom_ray_cast_2d.is_colliding():
		var body: Node2D = bottom_ray_cast_2d.get_collider()
		if body is EnemyBase:
			state = STATE.JUMP
			velocity.y += JUMP_VELOCITY
			
	if Input.is_action_pressed("Left"):
		state = STATE.MOVING_LEFT
		animated_sprite_2d.flip_h = true
			
	if Input.is_action_pressed("Right"):
		state = STATE.MOVING_RIGHT
		animated_sprite_2d.flip_h = false
			
	if Input.is_action_pressed("Dash"): # DASH IS INDEPENDENT OF OTHER EVENTS
		state = STATE.DASH
		
	if Input.is_action_pressed("Roll") and bottom_ray_cast_2d.is_colliding() and velocity.y == 0.0:
		state = STATE.ROLL
		$HitBoxComponent.disabled = true
		$RollHitBoxComponent.disabled = false
		
	else:
		$HitBoxComponent.disabled = false
		$RollHitBoxComponent.disabled = true
		
	if bottom_ray_cast_2d.is_colliding() and top_ray_cast_2d.is_colliding() \
	and bottom_ray_cast_2d.get_collider() is TileMapLayer and top_ray_cast_2d.get_collider() is TileMapLayer:
		state = STATE.ROLL
		$HitBoxComponent.disabled = true
		$RollHitBoxComponent.disabled = false
		
	if Input.is_action_pressed("Light_A"):
		state = STATE.LIGHT_ATTACK
		play_sound(SLASH)
	elif Input.is_action_pressed("Heavy_A"):
		state = STATE.HEAVY_ATTACK
		play_sound(SLASH)

		
	wasOnFloor = is_on_floor()
	hud.coins.text = str(coins)
	vfx.flip_h = animated_sprite_2d.flip_h
	previousDirection = dir if dir != 0 else previousDirection
	vfx.global_position = attack_box_left.global_position if vfx.flip_h else attack_box_right.global_position
		
func handleAnimationStateUpdate() -> void:
	var axis: float = Input.get_axis("Left", "Right")
	var animationName: String = ""
	
	if axis != 0.0:
		dash_particle.material.set_shader_parameter("facing_left", false if axis > 0 else true)
		
	match state:
		STATE.DEAD:
			animationName = "Dead"
		STATE.JUMP:
			animationName = "Jump"
		STATE.FALL:
			animationName = "Fall"
		STATE.MOVING_RIGHT, STATE.MOVING_LEFT:
			animationName = "Move" if velocity.y == 0.0 and is_on_floor() else ""
			velocity.x = move_toward(velocity.x, previousDirection * SPEED, acceleration)
		STATE.LIGHT_ATTACK:
			animationName = ["Light1", "Light2"].pick_random()
			var array = vfx.sprite_frames.get_animation_names() as Array[String]
			vfx.play(array.pick_random())
		STATE.HEAVY_ATTACK:
			animationName = "Light3"
			vfx.play("BigSlash")
		STATE.POWERUP:
			animationName = "PowerUP"
			velocity.x = move_toward(velocity.x, 0, friction)
		STATE.DASH:
			velocity.x = move_toward(velocity.x, previousDirection * SPEED * DASH_MULTIPLIER, acceleration)
			if velocity.y == 0.0:	
				dash_particle.emitting = true
				animationName = "Dash"
		STATE.ROLL:
			animationName = "Roll" if velocity.y == 0.0 else ""
		STATE.IDLE:
			animationName = "Idle"
			$HitBoxComponent.disabled = false
			$RollHitBoxComponent.disabled = true
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
	
	if state != STATE.DASH:
		dash_particle.emitting = false
			
func applyHitDamage(body: Node2D):
	animation_player.play("Hit")
	SignalManager.emit_signal("body_hit")
	if state == STATE.DEAD:
		return 
	if body is EnemyBase:
		knockBack(body)
		health = max(health - body.DAMAGE_POINT, 0.0)
	if body is Laser or body is SwingHammer or body is FanBlade or body is CrushingPlatform or body is Bullet:
		health = max(health - body.DAMAGE_POINT, 0.0)
	
	tweenProgressBar(hud.health, scaleHealth(health))
	
	if health <= 0.0:
		animated_sprite_2d.play("Dead")
		state = STATE.DEAD
		dash_particle.emitting = false
		dead_aimation.visible = true
		can_use_controls = false
		dead_aimation.flip_h = animated_sprite_2d.flip_h
		await get_tree().create_timer(1).timeout
		SignalManager.emit_signal("player_dead")
		
func _reset_player(checkpoint: Vector2) -> void:
	can_use_controls = true
	state = STATE.IDLE
	health = MAX_HEALTH
	dead_aimation.visible = false
	tweenProgressBar(hud.stamina, stamina, 1.0)
	tweenProgressBar(hud.health, scaleHealth(health), 1.0)
	global_position = Vector2(checkpoint.x, checkpoint.y)
	
func knockBack(enemy: EnemyBase) -> void:
	position.x -= KNOCKBACKVALUE if enemy.position.x > self.position.x else -KNOCKBACKVALUE

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation in ["Light1","Light2","Light3","AttackCombo", "Heavy", "Roll", "PowerUP"]:
		if is_on_floor():
			state = STATE.IDLE
		else:
			state = STATE.FALL
		
func _on_attack_box_component_body_entered(body: Node2D) -> void:
	if body is EnemyBase:
		if animated_sprite_2d.animation == "Light3":
			body.apply_damage(DAMAGE_POINT_HEAVY)
		else:
			body.apply_damage(DAMAGE_POINT)
			
