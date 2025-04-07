extends EnemyBase
class_name BatEnemy


var prev_x: float = 0.0
var prev_y: float = 0.0

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	super()
	SPEED *= 2
		#
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
	
	_attack_player()
				
				
func _attack_player() -> void:
	if state == STATE.ATTACK:
		return 
		
	if player:
		navigation_agent_2d.target_position = player.global_position
		
		
	var current_agent_position: Vector2 = global_position
	var next_path_pos: Vector2 = navigation_agent_2d.get_next_path_position()
	var direction: Vector2 = current_agent_position.direction_to(next_path_pos)
	var distance: float = global_position.distance_to(player.global_position)
	
	velocity = direction * SPEED	
	change_direction_of_sprite_animation(direction[0])
	
	if navigation_agent_2d.is_navigation_finished() or distance <= 23.0:
		animated_sprite_2d.play("Attack 1")
		state = STATE.ATTACK
	
func getGravity() -> float:
	if state != STATE.DEAD:
		return 0.0
	return JUMP_GRAVITY if velocity.y < 0.0 else FALL_GRAVITY
	
func _on_detect_player_area_body_entered(body: Node2D) -> void:
	if state != STATE.DEAD and body is Player:
		player = body
		parolePath = false
		call_deferred("navigation_agent_setup", body)
		
		
func navigation_agent_setup(body: Node2D) -> void:
	await get_tree().physics_frame
	if player:
		navigation_agent_2d.target_position = player.global_position
