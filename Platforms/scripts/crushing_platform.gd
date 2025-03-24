extends Node2D
class_name CrushingPlatform

var DAMAGE_POINT: float = 10

func _on_damage_area_body_entered(body: Node2D) -> void:
	if body is Player:
		body.applyHitDamage(self)
