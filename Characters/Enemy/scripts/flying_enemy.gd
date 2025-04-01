extends EnemyBase
class_name BatEnemy



func _ready() -> void:
	super()
	SPEED *= 3
		
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
	if not player:
		return 
		
	if player.state == player.STATE.DEAD:
		parolePath = true
		state = STATE.IDLE
		return 
		
	var angle: float = atan2(player.global_position.y - global_position.y, player.global_position.x - global_position.x)
	var distance: float = player.global_position.distance_to(global_position)
	var dir_x: float = round(cos(angle))
	var dir_y: float = round(sin(angle))
	velocity.x = dir_x * SPEED
	velocity.y = dir_y * SPEED
	
	change_direction_of_sprite_animation(dir_x)
	detect_obstacle_while_following_player()
	_attack_player(distance, dir_x)
				
				
func getGravity() -> float:
	if state != STATE.DEAD:
		return 0.0
	return JUMP_GRAVITY if velocity.y < 0.0 else FALL_GRAVITY
