extends Node2D

@export var freeze_slow := 0.07
@export var freeze_time := 0.4

@onready var camera_2d: Camera2D = $Player/Camera2D
@onready var player: Player = $Player
@onready var companion: Companion = $Companion
@onready var props_layer: TileMapLayer = $TileMap/PropsLayer
@onready var cinematic: CanvasLayer = $UserInterface/Cinematic
@onready var left_pos: Marker2D = $Player/LeftPos
@onready var right_pos: Marker2D = $Player/RightPos
@onready var companion_location: Node2D = $Player/CompanionLocation
@onready var camera_pos: Marker2D = $Player/CameraPos

const ENEMY_SHAKE_AMOUNT: int = 3
const FALL_SHAKE_AMOUNT: int = 5

var speed: float = 7.0
var companionScaleX: float = 0.0
var shake_amount: int 
var cameraShake: bool = false
var isCinematic: bool = false


func _ready() -> void:
	#Variables
	companionScaleX = companion.scale.x
	companion.companionCanFollowPlayer = false
	camera_2d.zoom = Vector2(3,3)
	Engine.time_scale = 0.9
	#player.can_use_controls = false
	
	#Signals
	SignalManager.connect("enemy_hit", _freeze_engine)
	SignalManager.connect("large_fall_detected", _large_fall_detected)
	SignalManager.connect("terminal_control_signal_emit", _terminal_control)
	SignalManager.connect("remote_control_session_complete", _remote_control_session_complete)
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _process(delta: float) -> void:
	if cameraShake:
		camera_2d.set_offset(Vector2( \
		randf_range(-1.0, 1.0) * shake_amount, \
		randf_range(-1.0, 1.0) * shake_amount \
		))
	if not companion.companionCanFollowPlayer:
		return 
	var dir: float = Input.get_axis("Left", "Right")
	if dir > 0:
		companion_location.global_position = left_pos.global_position
	elif dir < 0:
		companion_location.global_position = right_pos.global_position
		
	companion.global_position = lerp(companion.global_position, companion_location.global_position, speed * delta)
	

func _input(event):
	if event.is_action_pressed("Control"):
		zoom_camera(Vector2(1, 1))  # Zoom in
	elif event.is_action_pressed("Zoom"):
		zoom_camera(Vector2(2, 2))  # Zoom in
	elif event.is_action_released("Zoom") or event.is_action_released("Control"):
		zoom_camera(Vector2(4, 4))  # Zoom out
		

func zoom_camera(target_zoom: Vector2, time: float = 0.4):
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(camera_2d, "zoom", target_zoom, time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func showDialogue(timeline: String) -> void:
	Dialogic.start(timeline)
	cinematic.visible = true
	player.can_use_controls = false
		
func _terminal_control(pos: Vector2, name: String) -> void:
	var platform: Node2D = null
	var previousDistance: float = INF
	if name.length() > 0:
		for plat: Node2D in $CanActivatePlatforms.get_children():
			if name == plat.name:
				platform = plat
				break
				
	if not platform or name.length() == 0:
		for plat: Node2D in $CanActivatePlatforms.get_children():
			var distance: float = pos.distance_to(plat.position)
			if distance < previousDistance:
				previousDistance = distance
				platform = plat
			
		
	if platform is HoverPlatform or platform is SwingHammer or platform is GateDoor:
		platform.activate()
	if platform is Laser:
		platform.deactivateLasers()
	if platform:
		player.can_use_controls = false
		camera_2d.global_position = platform.position
		await get_tree().create_timer(2).timeout
		camera_2d.global_position = camera_pos.global_position
		player.can_use_controls = true


func _freeze_engine() -> void:
	cameraShake = true
	shake_amount = ENEMY_SHAKE_AMOUNT
	Engine.time_scale = freeze_slow
	await get_tree().create_timer(freeze_time * freeze_slow).timeout
	cameraShake = false
	Engine.time_scale = 1
	
func _large_fall_detected() -> void:
	cameraShake = true
	shake_amount = FALL_SHAKE_AMOUNT
	await get_tree().create_timer(0.2).timeout
	cameraShake = false
	
func _remote_control_session_complete() -> void:
	camera_2d.make_current()
	player.can_use_controls = true
	
func _on_player_introduction_body_entered(body: Node2D) -> void:
	if body is Player:
		zoom_camera(Vector2(3,3), 2)
		await get_tree().create_timer(2).timeout
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
		
func _on_interact_body_entered(body: Node2D) -> void:
	if body is Player:
		showDialogue("timeline-tutorial-interact")
		$CinematicAreas/Interact.disconnect("body_entered", _on_interact_body_entered)
		
func DialogueDone() -> void:
	cinematic.visible = false
	player.can_use_controls = true
	
func _on_dialogic_signal(argument: String):
	if argument.length() > 0:
		DialogueDone()
	match argument:
		"timeline-2":
			companion.companionCanFollowPlayer= true
			companion.animated_sprite_2d.flip_h = false
		
