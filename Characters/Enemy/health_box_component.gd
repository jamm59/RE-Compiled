extends Area2D
class_name HealthBoxComponent

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var enemy_base: EnemyBase = $".."
@onready var dead_timer: Timer = $DeadTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $"../AnimatedSprite2D"
@onready var health_damage_text: Label = $"../LabelParent/HealthDamageText"

@export var MAX_HEALTH: int = 10


var health: float
var dir: int = 1
var isDead: bool = false

func _ready() -> void:
	health_damage_text.hide()
	health = MAX_HEALTH
	#
func apply_damage(damagePoint: int) -> void:
	if isDead:
		return 
	health -= damagePoint
	animation_player.play("Damage")
	
	if health <= 0:
		enemy_base.handleEnemyDead()
		dead_timer.start()
		
func knockBack() -> void:
	var axis: int = Input.get_axis("Left", "Right")
	if axis in [1, -1]:
		dir = axis
	enemy_base.position.x += 10  * dir
	
func emitHitSignal() -> void:
	print("hello world")
	SignalManager.emit_signal("enemy_hit")
	
func _on_dead_timer_timeout() -> void:
	isDead = true
	get_parent().queue_free()
