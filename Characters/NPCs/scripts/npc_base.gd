extends CharacterBody2D
class_name NPCBase

@onready var camera_2d: Camera2D = $Camera2D
@onready var animal: AnimatedSprite2D = $AnimalSprites/FoxCharacterBody2D2/Fox

@export_group("NPC Settings")
@export var is_animal: bool = true
@export var can_fly: bool = false
@export var remote_control_activated: bool = false


@export_category("Jump Settings")
@export var jump_height : float = 70
@export var jump_time_to_peak : float = 0.4
@export var jump_time_to_descent : float = 0.35


@onready var JUMP_VELOCITY : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var JUMP_GRAVITY : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var FALL_GRAVITY : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0


@export var speed: float = 150.0
@export var acceleration: float = 50.0
@export var friction: float = 40.0
@export var wall_speed: float = 100.0
@export var jump_force: float = -300.0

var toggleGravity: bool = false
var directionX: float = 0.0
var directionY: float = 0.0

enum NPCSTATE {IDLE, MOVE, JUMP,FALL, WALL_CLIMB}
var state: NPCSTATE = NPCSTATE.IDLE

func getGravity() -> float:
	return JUMP_GRAVITY if velocity.y < 0.0 else FALL_GRAVITY
	
	
func _ready() -> void:
	if remote_control_activated:
		camera_2d.make_current()
		
func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_input()
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += getGravity() * delta

func handle_input() -> void:
	directionX = Input.get_axis("Left", "Right")
	if not remote_control_activated:
		return 
	
	if not camera_2d.is_current():
		camera_2d.make_current()

	if directionX == 0:
		velocity.x = move_toward(velocity.x, 0, friction)
		state = NPCSTATE.IDLE
	
	if Input.is_action_pressed("Left"):
		velocity.x = move_toward(velocity.x, -1 * speed, acceleration)
		state = NPCSTATE.MOVE
		animal.flip_h = true
	if Input.is_action_pressed("Right"):
		velocity.x = move_toward(velocity.x, 1 * speed, acceleration)
		state = NPCSTATE.MOVE
		animal.flip_h = false
	
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jump_force
		state = NPCSTATE.JUMP
		
	if not is_on_floor() and velocity.y > 0:
		state = NPCSTATE.FALL
		
	match state:
		NPCSTATE.IDLE:
			animal.play("Eating")
		NPCSTATE.MOVE, NPCSTATE.JUMP, NPCSTATE.FALL:
			animal.play("Move")
