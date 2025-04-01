extends EnemyBase
class_name MiniBoss


const BULLET = preload("res://Characters/Enemy/scene/bullet.tscn")
@onready var enemy_group: Node2D = $".."

@onready var bullets: Node2D = $Bullets
@onready var bullet_start_marker: Marker2D = $BulletStartMarker
@onready var mcq_u_i: MCQ = $MCQ_U_I

@export var bullet_count: int = 3
var found_player_at: Vector2 = Vector2(0.0, 0.0)

const Enemies = [
	preload("res://Characters/Enemy/scene/monster.tscn"),
	preload("res://Characters/Enemy/scene/monster_2.tscn"),
	preload("res://Characters/Enemy/scene/monster_3.tscn"),
	preload("res://Characters/Enemy/scene/monster_4.tscn"),
	preload("res://Characters/Enemy/scene/monster_5.tscn"),
]


func _spawn_enemy() -> void:
	var enemy: EnemyBase = Enemies.pick_random().instantiate()
	enemy_group.call_deferred("add_child", enemy)
	enemy.global_position = Vector2(global_position.x + 5, global_position.y)
	enemy.visible = true
	enemy.player = player
	enemy.parolePath = false
	
func _create_bullets(n_of_bullets: int) -> void:
	for i in n_of_bullets:
		var bullet: Bullet = BULLET.instantiate()
		bullet.visible = false
		bullets.add_child(bullet)

func shoot_bullets(body: Player):
	var index: int = 0;
	var angle = atan2(body.global_position.y - global_position.y, body.global_position.x - global_position.x)
	var dir_x = round(cos(angle))
	for bullet: Bullet in bullets.get_children():
		if bullet.is_moving:
			continue
		bullet.visible = true
		await get_tree().create_timer(0.2 * index).timeout
		bullet.shoot(bullet_start_marker.global_position, dir_x)
		index += 1
		
func _ready() -> void:
	super()
	attackDistanceLeft = 100.0
	attackDistanceRight = 100.0
	_create_bullets(10)
	mcq_u_i.answer_wrong.connect(_answer_wrong)
	mcq_u_i.answer_correct.connect(_answer_correct)
	
	
func _answer_wrong() -> void:
	health  = 0.5 * MAX_HEALTH
	tweenProgressBar(progress_bar, scaleHealth(health), 0.5)
	mcq_u_i.delete_self()

func _answer_correct() -> void:
	pass
	
func _physics_process(delta: float) -> void:		
	super(delta)
	
func handlestate() -> void:
	if state == STATE.ATTACK:
		shoot_bullets(player)
		animated_sprite_2d.play("Attack 1")
		return 
		
	match state:
		STATE.RUN:
			animated_sprite_2d.play("Move")
		STATE.IDLE:
			animated_sprite_2d.play("Walk")
			
			
func apply_damage(damagePoint: int) -> void:
	if isDead:
		return 
	animation_player.play("Hit")
	health  = max(health - damagePoint, 0)
	tweenProgressBar(progress_bar, scaleHealth(health), 0.5)
	if health <= 80 and health >= 78:
		_spawn_enemy()
	if health <= 50 and health >= 48:
		Dialogic.start("timeline-mid-miniboss")
	elif health <= 20 and health >= 18:
		mcq_u_i.activate()
	if health <= 0:
		animation_player.play("Dead")
		handleEnemyDead()
		
#func _on_detect_player_area_body_entered(body: Node2D) -> void:
	#if state != STATE.DEAD and body is Player:
		#_spawn_enemy()
		#player = body
		#parolePath = false
