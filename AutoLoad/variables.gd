extends Node


func _launch(ref: CharacterBody2D, strength: float, direction: Vector2) -> void:
	ref.velocity += direction.normalized()  * strength
