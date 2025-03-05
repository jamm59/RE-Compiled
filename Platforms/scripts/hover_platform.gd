extends Node2D
class_name HoverPlatform

#gears
@onready var gear_sprites: Array = [
	$OtherGears/TopLeft,
	$OtherGears/TopRight,
	$OtherGears/BottomRight,
	$Gears/Small,
	$Gears/Medium,
	$Gears/Large
]

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var activate: bool  = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not activate: 
		return 
		
	activate = false
	animation_player.play("hover")
	for gear: AnimatedSprite2D in gear_sprites:
		gear.play("Spin")
	
		
	
