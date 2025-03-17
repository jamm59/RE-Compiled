class_name CrowNPC extends NPCBase

func _ready() -> void:
	super.initVariables()
	animal = $Crow
	
func _physics_process(delta: float) -> void:
	super(delta)

func tweenRotation(ref: Node2D, target_angle: float, time: float = 0.1) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(ref, "rotation_degrees", target_angle, time)

func handle_input(delta: float) -> void:
	super(delta)
	
	if direction == 0.0:
		velocity.x = move_toward(velocity.x, 0, friction)
		state = NPCSTATE.IDLE if velocity.y == 0.0 and velocity.x == 0.0 else NPCSTATE.MOVE

	if Input.is_action_just_pressed("Jump"):
		velocity.y = jump_force
		state = NPCSTATE.MOVE

	if not is_on_floor() and velocity.y > 0:
		state = NPCSTATE.FALL
		#tweenRotation(animal, -45) if animal.flip_h else tweenRotation(animal, 45)
	
	if not is_on_floor() and velocity.y < 0:
		tweenRotation(animal, 0, 0.15)
		
	if is_on_floor():
		animal.rotation_degrees = 0
