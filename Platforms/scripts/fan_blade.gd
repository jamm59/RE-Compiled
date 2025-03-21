extends Node2D
class_name FanBlade

#gears
@onready var gear_sprites: Array = [
	$Parent/Gear, $Parent/Extra/Gear2
]

@onready var fan: AnimatedSprite2D = $Parent/Fan
@onready var damage_area: Area2D = $DamageArea

const DAMAGE_POINT: int = 2

func _ready() -> void:
	activate()

func activate() -> void:
	fan.play("Spin")
	for gear: AnimatedSprite2D in gear_sprites:
		gear.play("Spin")
	damage_area.connect("body_entered", _on_damage_area_body_entered)


func _on_damage_area_body_entered(body: Node2D) -> void:
	if body is Player:
		body.applyHitDamage(self)
