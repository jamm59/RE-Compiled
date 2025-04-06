class_name CrowNPC extends NPCBase

func _ready() -> void:
	super.initVariables()
	npc = $Crow
	
func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	if not remote_control_activated:
		state = STATE.IDLE
	else:
		handle_input(delta)
	update_state_animation()
	move_and_slide()


func tweenRotation(ref: Node2D, target_angle: float, time: float = 0.1) -> void:
	var tween: Tween = get_tree().create_tween()

func handle_input(delta: float) -> void:
	super(delta)
	if direction == 0.0:
		velocity.x = move_toward(velocity.x, 0, friction)
		state = STATE.IDLE if velocity.y == 0.0 and velocity.x == 0.0 else STATE.MOVE

	if Input.is_action_just_pressed("Jump"):
		velocity.y = jump_force
		state = STATE.MOVE

	if not is_on_floor() and velocity.y > 0:
		state = STATE.FALL
		#tweenRotation(animal, -45) if animal.flip_h else tweenRotation(animal, 45)
	
	if not is_on_floor() and velocity.y < 0:
		tweenRotation(npc, 0, 0.15)
		
	if is_on_floor():
		npc.rotation_degrees = 0
