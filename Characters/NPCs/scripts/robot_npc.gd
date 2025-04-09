class_name RobotNPC extends NPCBase

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

@onready var bullet_location_left: Marker2D = $BulletLocationLeft
@onready var bullet_location_right: Marker2D = $BulletLocationRight
@onready var attack_timer: Timer = $AttackTimer
@onready var forward: Node2D = $Forward
@onready var bullets: Node2D = $bullets

@onready var duration: Timer = $Duration
@onready var timer: RichTextLabel = $timer


var duration_activated: bool = false
var can_shoot: bool = false
var wasOnFloor: bool = false

func _ready() -> void:
	npc = $Robot
	initVariables()
	
func _physics_process(delta: float) -> void:
	super(delta)
	
	if remote_control_activated and not duration_activated:
		duration.start(10)
		duration_activated = true
		
		for i in 10:
			await get_tree().create_timer(1).timeout
			timer.text = "[b][font_size=5]" + str(10 - i) + "..[/font_size][/b]"
		
		
	if is_on_floor() and not wasOnFloor:
		SignalManager.emit_signal("large_fall_detected")
		
	wasOnFloor = is_on_floor()

func handle_input(delta: float) -> void:
	super(delta)
	if Input.is_action_just_pressed("Light_A") or  Input.is_action_just_pressed("Heavy_A"):
		state = STATE.ATTACK

func update_state_animation() -> void:
	if state == STATE.ATTACK:
		forward.global_position = Vector2(global_position.x * 1000 * previousDirection, global_position.y)
		var shoot_from: Marker2D = bullet_location_left if npc.flip_h else bullet_location_right
		Variables.shoot_bullets(self, forward, bullets, shoot_from)
		npc.play("Attack 1")
		can_shoot = false
		return

	super()


func _on_attack_timer_timeout() -> void:
	can_shoot = true

func _on_robot_animation_finished() -> void:
	state = STATE.IDLE

func _on_duration_timeout() -> void:
	remote_control_activated = false
	SignalManager.emit_signal("npc_dead")
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is EnemyBase:
		remote_control_activated = true
