extends EnemyBase
class_name EnemyDuplicate

const MonsterDuplicate = preload("res://Characters/Enemy/scene/monster_5.tscn")

@onready var enemy_group: Node2D = $".."
@onready var spawn_left_location: Marker2D = $SpawnLeftLocation
@onready var spawn_right_location: Marker2D = $SpawnRightLocation

var status: String = "Parent"
var dir_x: int

func _ready() -> void:
	super()
	attackDistanceLeft = 20
	attackDistanceRight = 20
	if status != "Parent":
		animated_sprite_2d.material.set_shader_parameter("new_color", Color("#16c47f"))
	
func _physics_process(delta: float) -> void:
	super(delta)
	dir_x = Input.get_axis("Left", "Right")
	

func apply_damage(damagePoint: int) -> void:
	if isDead:
		return 
	animation_player.play("Hit")
	if status == "Parent":
		await get_tree().create_timer(0.3).timeout
		var n_monster: EnemyDuplicate = MonsterDuplicate.instantiate()
		n_monster.status = "Child"
		n_monster.player = player
		n_monster.parolePath = false
		
		match dir_x:
			1:
				n_monster.global_position = spawn_left_location.global_position
			-1:
				n_monster.global_position = spawn_right_location.global_position
			0:
				n_monster.global_position = global_position
				
		enemy_group.call_deferred("add_child", n_monster)

	health  = max(health - damagePoint, 0)
	if health <= 0:
		animation_player.play("Dead")
		handleEnemyDead()
		
	
