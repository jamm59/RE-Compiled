extends CharacterBody2D
class_name NPCBase

@onready var camera_2d: Camera2D = $Camera2D
@onready var npc: AnimatedSprite2D
@onready var ray_cast_right: RayCast2D = $RayCast/RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCast/RayCastLeft
@onready var ray_cast_left_ground: RayCast2D = $RayCast/RayCastLeftGround
@onready var ray_cast_right_ground: RayCast2D = $RayCast/RayCastRightGround

@export_group("NPC Settings")
@export var remote_control_activated: bool = false


@export_category("Jump Settings")
@export var jump_height : float = 55.0
@export var jump_time_to_peak : float = 0.35
@export var jump_time_to_descent : float = 0.4


@onready var JUMP_VELOCITY : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var JUMP_GRAVITY : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var FALL_GRAVITY : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0


var speed: float = 50.0
var acceleration: float = 50.0
var friction: float = 40.0
var wall_speed: float = 100.0
var jump_force: float = -300.0
var previousDirection: float = 1.0

var direction: float = [1.0, -1.0].pick_random()

var toggleGravity: bool = false
var npc_in_danger: bool = false 

enum STATE {IDLE, MOVE, JUMP,FALL, WALL_CLIMB, ATTACK}

var state: STATE = STATE.IDLE

func getGravity() -> float:
	return JUMP_GRAVITY if velocity.y < 0.0 else FALL_GRAVITY
	
	
func _ready() -> void:
	previousDirection = direction
	npc = $Fox
	initVariables()
		
func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	if not remote_control_activated:
		move_freely(delta)
	else:
		handle_input(delta)
	update_state_animation()
	move_and_slide()

func initVariables() -> void:
	if remote_control_activated:
		speed = 150
		camera_2d.make_current()
		
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += getGravity() * delta
		
func move_freely(delta: float) -> void:
	state = STATE.MOVE
	if not ray_cast_right_ground.is_colliding() or ray_cast_right.is_colliding():
		direction = -1
		npc.flip_h = true
		
	elif not ray_cast_left_ground.is_colliding() or ray_cast_left.is_colliding():
		direction = 1
		npc.flip_h = false

	
func handle_input(delta: float) -> void:
	direction = Input.get_axis("Left", "Right")
	if not remote_control_activated:
		return 
	
	if not camera_2d.is_current():
		camera_2d.make_current()

	if direction == 0.0:
		velocity.x = move_toward(velocity.x, 0, friction)
		state = STATE.IDLE if velocity.y == 0.0 else STATE.MOVE
	else:
		previousDirection = direction
	
	if Input.is_action_pressed("Left") or Input.is_action_pressed("Right"):
		state = STATE.MOVE
		if direction != 0.0:
			npc.flip_h = false if direction > 0 else true
		
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jump_force
		state = STATE.JUMP
		
	if not is_on_floor() and velocity.y > 0:
		state = STATE.FALL
		
func update_state_animation() -> void:
	if remote_control_activated:
		speed = 150
		
	match state:
		STATE.IDLE:
			velocity.x = move_toward(velocity.x, 0.0, friction)
			var hasEatingAnimation: bool = npc.sprite_frames.get_animation_names().has("Eating")
			if not hasEatingAnimation and not remote_control_activated:
				npc.play("Idle")
			elif hasEatingAnimation and not remote_control_activated:
				npc.play("Eating")
			if remote_control_activated:
				npc.play("Idle")
		STATE.MOVE, STATE.JUMP, STATE.FALL:
			npc.play("Move")
			if remote_control_activated:
				velocity.x = move_toward(velocity.x, previousDirection * speed, acceleration)
			else:
				velocity.x = move_toward(velocity.x, direction * speed, acceleration)
