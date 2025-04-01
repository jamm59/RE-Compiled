class_name FerretNPC extends NPCBase


func _ready() -> void:
	animal = $Ferret
	initVariables()

func _physics_process(delta: float) -> void:
	super(delta)

func update_state_animation() -> void:
	if remote_control_activated:
		speed = 150
		
	match state:
		STATE.IDLE:
			velocity.x = move_toward(velocity.x, 0.0, friction)
			var hasEatingAnimation: bool = animal.sprite_frames.get_animation_names().has("Eating")
			if not hasEatingAnimation and not remote_control_activated:
				animal.play("Idle")
			elif hasEatingAnimation and not remote_control_activated:
				animal.play("Eating")
			if remote_control_activated:
				animal.play("Idle")
		STATE.MOVE:
			animal.play("Move")
			if remote_control_activated:
				velocity.x = move_toward(velocity.x, previousDirection * speed, acceleration)
			else:
				velocity.x = move_toward(velocity.x, direction * speed, acceleration)
		STATE.JUMP:
			animal.play("Jump")
		STATE.FALL:
			animal.play("Fall")
