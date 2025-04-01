extends Control

@onready var player_sprite_sheet: AnimatedSprite2D = $CanvasLayer/PlayerSpriteSheet


func _on_color_picker_button_color_changed(color: Color) -> void:
	player_sprite_sheet.material.set_shader_parameter("new_color", color)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/Level 0/Game.tscn")
