extends Node2D
class_name FanBlade

#gears
@onready var gear_sprites: Array = [
	$Parent/Gear, $Parent/Extra/Gear2
]

@onready var fan: AnimatedSprite2D = $Parent/Fan
@onready var damage_area: Area2D = $DamageArea
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

const DAMAGE_POINT: int = 2

func activate() -> void:
	fan.play("Spin")
	for gear: AnimatedSprite2D in gear_sprites:
		gear.play("Spin")
	damage_area.connect("body_entered", _on_damage_area_body_entered)
	cpu_particles_2d.emitting = true


func _on_damage_area_body_entered(body: Node2D) -> void:
	if body is Player:
		body.applyHitDamage(self)
