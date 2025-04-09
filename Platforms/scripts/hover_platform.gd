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
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


func activate() -> void:
	audio_stream_player_2d.playing = true
	animation_player.play("hover")
	for gear: AnimatedSprite2D in gear_sprites:
		gear.play("Spin")

		
	
