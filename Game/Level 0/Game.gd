extends Node2D

@export var freeze_slow := 0.07
@export var freeze_time := 0.4

@onready var camera_2d: Camera2D = $Player/Camera2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player: Player = $Player
@onready var companion: Companion = $Companion
@onready var props_layer: TileMapLayer = $TileMap/PropsLayer
@onready var cinematic: CanvasLayer = $UserInterface/Cinematic

var tween:Tween = null

var speed: float = 7.0
var companionScaleX: float = 0.0
var shake_amount: int = 3
var cameraShake: bool = false
var isCinematic: bool = false


		
func _ready() -> void:
	#Variables
	tween = get_tree().create_tween()
	companionScaleX = companion.scale.x
	companion.companionCanFollowPlayer = false
	Engine.time_scale = 0.9
	#player.can_use_controls = false
	
	#Signals
	SignalManager.connect("enemy_hit", _freeze_engine)
	SignalManager.connect("terminal_control_signal_emit", _terminal_control)
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _process(delta: float) -> void:
	if cameraShake:
		camera_2d.set_offset(Vector2( \
		randf_range(-1.0, 1.0) * shake_amount, \
		randf_range(-1.0, 1.0) * shake_amount \
		))
	if not companion.companionCanFollowPlayer:
		return 
	companion.position = lerp($Companion.global_position, $Player/CompanionLocation.global_position, speed * delta)
	

func _input(event):
	if event.is_action_pressed("Zoom"):
		zoom_camera(Vector2(1, 1))  # Zoom in
	elif event.is_action_released("Zoom"):
		zoom_camera(Vector2(4, 4))  # Zoom out

func zoom_camera(target_zoom: Vector2):
	if tween:
		tween.kill()
	# Create a new tween
	tween = get_tree().create_tween()
	tween.tween_property(camera_2d, "zoom", target_zoom, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func showDialogue(timeline: String) -> void:
	Dialogic.start(timeline)
	cinematic.visible = true
	player.can_use_controls = false
		
func _terminal_control(pos: Vector2) -> void:
	var platform: Node2D = null
	var previousDistance: float = INF
	for plat: Node2D in $MovementPlatforms.get_children():
		var distance: float = pos.distance_to(plat.position)
		if distance < previousDistance:
			previousDistance = distance
			platform = plat
	
	if platform is HoverPlatform:
		platform.activate = true

func _freeze_engine() -> void:
	cameraShake = true
	Engine.time_scale = freeze_slow
	await get_tree().create_timer(freeze_time * freeze_slow).timeout
	cameraShake = false
	Engine.time_scale = 1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		animation_player.play("start")
		camera_2d.position_smoothing_enabled = true
		Engine.time_scale = 1
		$CinematicAreas/SceneOne.disconnect("body_entered", _on_area_2d_body_entered)

func _on_player_introduction_body_entered(body: Node2D) -> void:
	if body is Player:
		showDialogue("timeline-1")
		$CinematicAreas/PlayerIntroduction.disconnect("body_entered", _on_player_introduction_body_entered)

func _on_companion_introduction_body_entered(body: Node2D) -> void:
	if body is Player:
		showDialogue("timeline-2")
		$CinematicAreas/CompanionIntroduction.disconnect("body_entered", _on_companion_introduction_body_entered)
		
func _on_jump_area_scene_body_entered(body: Node2D) -> void:
	if body is Player:
		showDialogue("timeline-tutorial-jump")
		$CinematicAreas/JumpAreaScene.disconnect("body_entered", _on_jump_area_scene_body_entered)
		
func _on_first_enemy_scene_body_entered(body: Node2D) -> void:
	if body is Player:
		showDialogue("timeline-first-enemy")
		$CinematicAreas/FirstEnemyScene.disconnect("body_entered", _on_first_enemy_scene_body_entered)
		
func _on_enemy_encounter_two_scene_body_entered(body: Node2D) -> void:
	if body is Player:
		showDialogue("timeline-enemy-encounter")
		$CinematicAreas/EnemyEncounterTwoScene.disconnect("body_entered", _on_enemy_encounter_two_scene_body_entered)
		
func DialogueDone() -> void:
	cinematic.visible = false
	player.can_use_controls = true
	
func _on_dialogic_signal(argument: String):
	if argument.length() > 0:
		DialogueDone()
	match argument:
		"timeline-1":
			pass
		"timeline-2":
			companion.companionCanFollowPlayer= true
			companion.animated_sprite_2d.flip_h = false
		"timeline-first-enemy":
			pass
		"timeline-tutorial-controls":
			pass
		"timeline-tutorial-jump":
			pass
		"timeline-tutorial-interact":
			pass
		"timeline-enemy-encounter":
			pass
		


func _on_interact_body_entered(body: Node2D) -> void:
	if body is Player:
		showDialogue("timeline-tutorial-interact")
