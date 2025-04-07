extends EnemyBase
class_name TimeScaleEnemy

func _ready() -> void:
	super()
	
func _physics_process(delta: float) -> void:
	super(delta)
	
func handleEnemyDead() -> void:
	super()
	Engine.time_scale = 1.0
	
	
func _attack_player() -> void:
	var angle: float = atan2(player.global_position.y - global_position.y, player.global_position.x - global_position.x)
	var distance: float = player.global_position.distance_to(global_position)
	var dir_x: float = round(cos(angle))
	
	if distance >= 300.0:
		Variables._launch(self, 400, Vector2(dir_x, 1))
	
	if distance <= 100:
		Engine.time_scale = 0.5
	else:
		Engine.time_scale = 1.0

	var is_player_to_the_left: bool = global_position.x > player.global_position.x
	var is_player_to_the_right: bool = global_position.x < player.global_position.x

	# If player is within attack range, trigger attack animationa
	if (is_player_to_the_left and distance <= attackDistanceLeft) or \
		(is_player_to_the_right and distance <= attackDistanceRight):
		state = STATE.ATTACK
		animated_sprite_2d.play("Attack 1")  # Start attack animation
	else:
		state = STATE.RUN
		velocity.x = move_toward(velocity.x, dir_x * SPEED, acceleration)
	
	change_direction_of_sprite_animation(dir_x)
	detect_obstacle_while_following_player()
