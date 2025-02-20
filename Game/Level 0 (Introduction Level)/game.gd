extends Node2D

@export var freeze_slow := 0.07
@export var freeze_time := 0.3

@onready var camera_2d: Camera2D = $Player/Camera2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player: Player = $Player
@onready var companion: Node2D = $Companion
@onready var props_layer: TileMapLayer = $TileMap/PropsLayer

var speed: float = 5.0
var companionScaleX: float = 0.0
var companionCanFollowPlayer: bool = false
var shake_amount = 3
var cameraShake = false



func processLadderCollision() -> void:
	for cell in props_layer.get_used_cells():
		var tile = props_layer.get_cell_tile_data(cell)
		if tile:
			print(tile.get_custom_data("Ladder"))
	
	
func _ready() -> void:
	companionScaleX = companion.scale.x
	player.can_use_controls = false
	Engine.time_scale = 0.9
	SignalManager.connect("enemy_hit", freeze_engine)

	#processLadderCollision()	
func _process(delta: float) -> void:
	if cameraShake:
		camera_2d.set_offset(Vector2( \
		randf_range(-1.0, 1.0) * shake_amount, \
		randf_range(-1.0, 1.0) * shake_amount \
		))
	if not companionCanFollowPlayer:
		return 
	companion.position = lerp($Companion.global_position, $Player/CompanionLocation.global_position, speed * delta)
	
func freeze_engine() -> void:
	cameraShake = true
	Engine.time_scale = freeze_slow
	await get_tree().create_timer(freeze_time * freeze_slow).timeout
	cameraShake = false
	Engine.time_scale = 1


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		animation_player.play("start")
		Engine.time_scale = 1
		body.can_use_controls = true
		$StartArea.disconnect("body_entered", _on_area_2d_body_entered)
	


func _on_companion_introduction_body_entered(body: Node2D) -> void:
	if body is Player:
		companionCanFollowPlayer = true
		$CompanionIntroduction.disconnect("body_entered", _on_companion_introduction_body_entered)
