extends EnemyBase
class_name BatN



func _ready() -> void:
	super()
		
	
func _physics_process(delta: float) -> void:
	super(delta)   


func handleMoveAndAvoidObstacles()-> void:
	velocity.x = start_direction * SPEED
	if ray_cast_left_ground.is_colliding() or ray_cast_left.is_colliding() or ray_cast_top_left.is_colliding():
		start_direction = 1
		animated_sprite_2d.flip_h = false
		
	elif ray_cast_right_ground.is_colliding() or ray_cast_right.is_colliding() or ray_cast_top_right.is_colliding():
		start_direction = -1
		animated_sprite_2d.flip_h = true
		
func handleFollowPlayerLogic() -> void:
	if player != null:
		if player.state == player.STATE.DEAD:
			followPath = true
			state = STATE.IDLE
			return 
		var player_position = player.global_position
		var angle_between_enemy_and_player = atan2(player_position.y - global_position.y, player_position.x - global_position.x)
		var dir_x = round(cos(angle_between_enemy_and_player))
		var dir_y = round(sin(angle_between_enemy_and_player))
		velocity.x = dir_x * SPEED
		velocity.y = dir_y * SPEED
		
		if dir_x == 1:
			animated_sprite_2d.flip_h = false
		elif dir_x == -1:
			animated_sprite_2d.flip_h = true
			
		if ray_cast_left.is_colliding() or ray_cast_right.is_colliding():
			for coll in [ray_cast_left, ray_cast_right]:
				var body = coll.get_collider()
				if not body:
					continue
				if (body is TileMapLayer and is_on_wall()) or (body is EnemyBase and body.state == body.STATE.DEAD): # Tilemap base layer
					global_position.y = player_position.y - 10
		else:
			state = STATE.RUN
				
				
func apply_gravity(delta: float) -> void:
	pass
