extends Node2D
class_name HoverPlatform

#gears
@onready var gear_sprites: Array = [
	$OtherGears/TopLeft,
	$OtherGears/TopRight,
	$Gears/Small,
	$Gears/Medium,
	$Gears/Large
]

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func activate() -> void:
	animation_player.play("hover")
	for gear: AnimatedSprite2D in gear_sprites:
		gear.play("Spin")

		
	
