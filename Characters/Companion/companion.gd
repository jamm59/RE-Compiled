extends Node2D
class_name Companion

enum CompanionState {IDLE, MOVE}


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var bullet_start_location: Marker2D = $BulletStartLocation
@onready var bullets: Node2D = $Bullets
@onready var attack_timer: Timer = $AttackTimer

@export var left_pos: Marker2D
@export var right_pos: Marker2D
@export var companion_location: Marker2D

@export var companion_can_follow: bool = false
@export var activate_companion_controls: bool = true

var can_shoot: bool = false
var state: CompanionState = CompanionState.IDLE
var speed: float = 4.0
var direction: float = 0.0
var enemy: EnemyDuplicate = null
var hasPermissionToShoot: bool = false


func move(delta: float) -> void:
	if not companion_can_follow:
		return 
	direction = Input.get_axis("Left", "Right")
	if direction != 0.0:
		if activate_companion_controls:
			companion_location.global_position = left_pos.global_position if direction > 0.0 else right_pos.global_position
	global_position = lerp(global_position, companion_location.global_position, speed * delta)
	if enemy and can_shoot:
		can_shoot = false
		attack_timer.start(1.0)
		Variables.shoot_bullets(self, enemy, bullets, bullet_start_location, true)
		#animated_sprite_2d.play("Attack 1")
		
	handleInput()
	handleAnimationState()

func handleInput() -> void:
	if direction == 0.0:
		state = CompanionState.IDLE
	else:
		if activate_companion_controls:
			state = CompanionState.MOVE
			animated_sprite_2d.flip_h = true if direction > 0.0 else false
		
func handleAnimationState() -> void:
	match state:
		CompanionState.IDLE:
			animated_sprite_2d.play("Idle")
		CompanionState.MOVE:
			animated_sprite_2d.play("Move")
			
		
func _on_detect_enemy_area_body_entered(body: Node2D) -> void:
	if body is EnemyDuplicate and hasPermissionToShoot:
		enemy = body
		can_shoot = true
		


func _on_attack_timer_timeout() -> void:
	can_shoot = true
