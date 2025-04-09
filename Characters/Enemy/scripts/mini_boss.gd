extends EnemyBase
class_name MiniBoss

@export var spawn_location: Array[Marker2D]

@onready var enemy_group: Node2D = $".."
@onready var bullets_parent: Node2D = $Bullets
@onready var mcq_u_i: MCQ = $MCQ_U_I
@onready var task: RichTextLabel = $Task
@export var bullet_count: int = 3

#@onready var bullet_location_left: Marker2D = $BulletLocationLeft
#@onready var bullet_location_right: Marker2D = $BulletLocationRight

var found_player_at: Vector2 = Vector2(0.0, 0.0)

var can_shoot: bool = true

const Enemies = [
	#preload("res://Characters/Enemy/scene/monster.tscn"),
	preload("res://Characters/Enemy/scene/monster_2.tscn"),
	preload("res://Characters/Enemy/scene/monster_3.tscn"),
	preload("res://Characters/Enemy/scene/monster_4.tscn"),
	preload("res://Characters/Enemy/scene/bat_eyes.tscn"),
	#preload("res://Characters/Enemy/scene/monster_5.tscn"),
]


func _spawn_enemy() -> void:
	var location: Marker2D = spawn_location.pick_random()
	textTypingAnimation("Spawning....")
	if spawn_location:
		var enemy: EnemyBase = Enemies.pick_random().instantiate()
		enemy_group.call_deferred("add_child", enemy)
		enemy.global_position = Vector2(location.global_position.x + 5, location.global_position.y)
		enemy.visible = true
		enemy.player = player
		enemy.parolePath = false
		
		
func _ready() -> void:
	super()
	textTypingAnimation(str(health) + " %...")
	attackDistanceLeft = 50.0
	attackDistanceRight = 50.0
	mcq_u_i.answer_wrong.connect(_answer_wrong)
	mcq_u_i.answer_correct.connect(_answer_correct)
	
	
func _answer_wrong() -> void:
	health  = 0.5 * MAX_HEALTH
	mcq_u_i.delete_self()

func _answer_correct() -> void:
	apply_damage(5)
	
func _physics_process(delta: float) -> void:
	super(delta)
			
func textTypingAnimation(text: String) -> void:
	var content: String = ""
	for s: String in text:
		await get_tree().create_timer(0.05).timeout
		content += s
		task.text = "[b][font_size=5]" + content + "[/font_size][/b]"
	
func apply_damage(damagePoint: int) -> void:
	if isDead:
		return 
	animation_player.play("Hit")
	var prevHealth: float = health
	var percentage: float = 30
	health  = max(health - damagePoint, 0)
# checking if we cross a multiple of percentage threshold
	if int(prevHealth / percentage) > int(health / percentage):
		_spawn_enemy()
	if health <= 50 and health >= 48:
		Dialogic.start("timeline-mid-miniboss")
	elif health <= 20 and health >= 18:
		mcq_u_i.activate()
	if health <= 0:
		animation_player.play("Dead")
		await get_tree().create_timer(0.6).timeout	
		handleEnemyDead()
		
	textTypingAnimation(str(health) + "%...")
		
func _on_detect_player_area_body_entered(body: Node2D) -> void:
	if state != STATE.DEAD and body is Player:
		player = body
		parolePath = false
