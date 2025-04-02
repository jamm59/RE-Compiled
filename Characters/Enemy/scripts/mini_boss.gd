extends EnemyBase
class_name MiniBoss

@export var spawn_location: Array[Marker2D]


@onready var enemy_group: Node2D = $".."
@onready var bullets_parent: Node2D = $Bullets
@onready var bullet_start_location: Marker2D = $BulletStartMarker
@onready var mcq_u_i: MCQ = $MCQ_U_I

@export var bullet_count: int = 3
var found_player_at: Vector2 = Vector2(0.0, 0.0)

const Enemies = [
	preload("res://Characters/Enemy/scene/monster.tscn"),
	preload("res://Characters/Enemy/scene/monster_2.tscn"),
	preload("res://Characters/Enemy/scene/monster_3.tscn"),
	preload("res://Characters/Enemy/scene/monster_4.tscn"),
	#preload("res://Characters/Enemy/scene/monster_5.tscn"),
]


func _spawn_enemy() -> void:
	var location: Marker2D = spawn_location.pick_random()
	if spawn_location:
		var enemy: EnemyBase = Enemies.pick_random().instantiate()
		enemy_group.call_deferred("add_child", enemy)
		enemy.global_position = Vector2(location.global_position.x + 5, location.global_position.y)
		enemy.visible = true
		enemy.player = player
		enemy.parolePath = false
		
		
func _ready() -> void:
	super()
	attackDistanceLeft = 100.0
	attackDistanceRight = 100.0
	Variables._create_bullets(10, bullets_parent)
	mcq_u_i.answer_wrong.connect(_answer_wrong)
	mcq_u_i.answer_correct.connect(_answer_correct)
	
	
func _answer_wrong() -> void:
	health  = 0.5 * MAX_HEALTH
	mcq_u_i.delete_self()

func _answer_correct() -> void:
	apply_damage(5)
	
func _physics_process(delta: float) -> void:		
	super(delta)
	
func handlestate() -> void:
	if state == STATE.ATTACK:
		Variables.shoot_bullets(self, player, bullets_parent, bullet_start_location)
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
	var prevHealth: float = health
	health  = max(health - damagePoint, 0)
	if int(prevHealth / 20) > int(health / 20): # checking if we cross a multiple of 20 threshold
		_spawn_enemy()
	if health <= 50 and health >= 48:
		_spawn_enemy()
		_spawn_enemy()
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
