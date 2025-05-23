class_name DeerNPC extends NPCBase

func _ready() -> void:
	npc = $Deer
	super.initVariables()
		
func _physics_process(delta: float) -> void:
	super(delta)   

func move_freely(delta: float) -> void:	
	for ray: RayCast2D in [ray_cast_right, ray_cast_right_ground,ray_cast_left, ray_cast_left_ground]:
		if ray.get_collider() is GrassFood:
			state = STATE.IDLE
			var grassFood: GrassFood = ray.get_collider()
			if grassFood.foodHealth <= 0.0:
				grassFood.queue_free()
			else:
				grassFood.foodHealth -= 0.8 * delta
			return
			
	state = STATE.MOVE
	velocity.x = direction * speed
		
	if not ray_cast_right_ground.is_colliding() or ray_cast_right.is_colliding():
		direction = -1
		npc.flip_h = true
		
	elif not ray_cast_left_ground.is_colliding() or ray_cast_left.is_colliding():
		direction = 1
		npc.flip_h = false
		
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		npc.play("Detected")
		$Area2D.disconnect("body_entered", _on_area_2d_body_entered)

func _on_deer_animation_finished() -> void:
	if npc.animation == "Detected":
		npc.play("Idle")
