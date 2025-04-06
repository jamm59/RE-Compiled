class_name FerretNPC extends NPCBase


func _ready() -> void:
	npc = $Ferret
	initVariables()

func _physics_process(delta: float) -> void:
	super(delta)

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
		STATE.MOVE:
			npc.play("Move")
			if remote_control_activated:
				velocity.x = move_toward(velocity.x, previousDirection * speed, acceleration)
			else:
				velocity.x = move_toward(velocity.x, direction * speed, acceleration)
		STATE.JUMP:
			npc.play("Jump")
		STATE.FALL:
			npc.play("Fall")
