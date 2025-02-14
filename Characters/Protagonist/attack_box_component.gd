extends Area2D
class_name AttackBoxComponent
@onready var animated_sprite_2d: AnimatedSprite2D = $"../AnimatedSprite2D"
@onready var attack_box: CollisionShape2D = $AttackBox

const DAMAGE_POINT: int = 2


func _ready() -> void:
	attack_box.disabled = true
	
	
func _process(delta: float) -> void:
	if Input.is_action_pressed("Attack"):
		attack_box.disabled = false
	else:
		attack_box.disabled = true



func _on_area_entered(area: Area2D) -> void:
	if area is HealthBoxComponent:
		area.apply_damage(DAMAGE_POINT)
