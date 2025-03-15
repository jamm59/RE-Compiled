extends Node2D
class_name Laser

@onready var laser_layers: Node2D = $LaserLayers
@onready var head: AnimatedSprite2D = $Head

func deactivateLasers() -> void:
	for laser: AnimatedSprite2D in laser_layers.get_children():
		await get_tree().create_timer(0.02).timeout
		laser.play_backwards("TurnOn")
	head.play_backwards("TurnOn")
	$LaserArea.disconnect("body_entered", _on_laser_area_body_entered)
	
func _on_laser_area_body_entered(body: Node2D) -> void:
	if body is Player:
		print("Applying serious damage")
