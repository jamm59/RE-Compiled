extends Node2D
class_name Game

const SAVE_GAME_PATH: String = "res://Resources/game-save/game-save.gd"


@export var freeze_slow := 0.07
@export var freeze_time := 0.4

@onready var camera_2d: Camera2D = $Player/Camera2D
@onready var player: Player = $Player
@onready var companion: Companion = $Companion
@onready var cinematic: CanvasLayer = $UserInterface/Cinematic
@onready var camera_pos: Marker2D = $Player/CameraPos
@onready var title_card: TitleCard = $UserInterface/TitleCard


const ENEMY_SHAKE_AMOUNT: int = 3
const FALL_SHAKE_AMOUNT: int = 5

var checkpoint: Vector2 = Vector2(0, 0)
var zoomValue: float = 3
var defaultZoom: Vector2 = Vector2(zoomValue, zoomValue)

var shake_amount: int 
var cameraShake: bool = false

var gs: GameStateSave = GameStateSave.new()

func _ready() -> void:
	#Loading saves
	if gs:
		gs.load_savegame(self)
		
	#Variables
	camera_2d.zoom = defaultZoom
	Engine.time_scale = 0.9
	#player.can_use_controls = false
	Dialogic.Inputs.auto_advance.per_word_delay = 0.3
	Dialogic.Inputs.auto_advance.per_character_delay = 0.1

	#Signals
	SignalManager.connect("body_hit", _freeze_engine)
	SignalManager.connect("enemy_dead", _on_enemy_dead)
	SignalManager.connect("player_dead", _on_player_dead)
	SignalManager.connect("npc_dead", reset_camera_position)
	SignalManager.connect("last_checkpoint", _last_checkpoint)
	SignalManager.connect("searching_signal", _searching_signal)
	SignalManager.connect("large_fall_detected", _large_fall_detected)
	SignalManager.connect("terminal_control_signal_emit", _terminal_control)
	SignalManager.connect("termianl_control_npc_signal", _short_range_terminal_control)
	SignalManager.connect("remote_control_session_complete", _remote_control_session_complete)
	SignalManager.connect("termianl_control_education_signal", _terminal_control_education_signal)
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _process(delta: float) -> void:
	if cameraShake:
		camera_2d.set_offset(Vector2( \
		randf_range(-1.0, 1.0) * shake_amount, \
		randf_range(-1.0, 1.0) * shake_amount \
		))
		
	companion.move(delta)

func _input(event) -> void:
	if Input.is_action_just_pressed("Skip_Dialogue") and Dialogic.current_timeline:
		var current_timeline: String = Dialogic.current_timeline.get_identifier()
		Dialogic.emit_signal("signal_event", current_timeline)
		
	if event.is_action_pressed("Control"):
		zoom_camera(Vector2(1, 1))  # Zoom in
	elif event.is_action_pressed("Zoom"):
		zoom_camera(Vector2(2, 2))  # Zoom in
	elif event.is_action_released("Zoom") or event.is_action_released("Control"):
		zoom_camera(defaultZoom)  # Zoom out
		
func _last_checkpoint() -> void:
	player.global_position = checkpoint

	
func zoom_camera(target_zoom: Vector2, time: float = 0.4):
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(camera_2d, "zoom", target_zoom, time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func showDialogue(timeline: String) -> void:
	companion.activate_companion_controls = false
	player.hud.visible = false
	player.can_use_controls = false
	cinematic.visible = true
	Dialogic.start(timeline)
		
func DialogueDone() -> void:
	Dialogic.end_timeline(true)
	cinematic.visible = false
	player.hud.visible = true
	player.can_use_controls = true
	companion.activate_companion_controls = true
	
func _short_range_terminal_control(pos: Vector2, name: String) -> void:
	var npc_animal: Node2D = null
	var previousDistance: float = INF
	if name.length() > 0:
		for npc: Node2D in $NPCs.get_children():
			if name == npc.name:
				npc_animal = npc
				break
				
	if not npc_animal or name.length() == 0:
		for npc: Node2D in $NPCs.get_children():
			var distance: float = pos.distance_to(npc.global_position)
			if distance < previousDistance:
				previousDistance = distance
				npc_animal = npc
	
	if previousDistance <= 600.0:
		if npc_animal is FerretNPC or npc_animal is CrowNPC or npc_animal is RobotNPC:
			npc_animal.remote_control_activated = true
			player.can_use_controls = false
			player.hud.status.text= "CONNECTED..."
	else:
		player.hud.status.text= "NOT FOUND..."
	
	
				
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
			
	activatePlatform(platform)

func _terminal_control_education_signal(pos: Vector2, name: String, activate_multiple: bool) -> void:
	if activate_multiple:
		for plat: Node2D in $Platforms.get_children():
			if plat.name.contains(name):
				if plat is LargeElevator:
					player.hud.status.text= "ACTIVATING..."
					activatePlatform(plat)
		return
	
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
		
	activatePlatform(platform)
	
func reset_camera_position() -> void:
	cinematic.visible = false
	player.hud.visible = true
	player.can_use_controls = true
	camera_2d.global_position = camera_pos.global_position

func activatePlatform(platform: Node2D) -> void:
	if platform is HoverPlatform or platform is SwingHammer or platform is GateDoor or platform is LargeElevator:
		platform.activate()
	if platform is FanBlade:
		platform.activate()
		$GravityRoomArea/CollisionShape2D.disabled = false
	if platform is Laser:
		platform.deactivateLasers()
	if platform:
		cinematic.visible = true
		player.hud.visible = false
		player.can_use_controls = false
		camera_2d.global_position = platform.global_position
		player.hud.status.text= "ACTIVATING..."
		await get_tree().create_timer(2).timeout
		cinematic.visible = false
		player.hud.visible = true
		player.can_use_controls = true
		camera_2d.global_position = camera_pos.global_position
		player.hud.status.text= "ACTIVATED..."
	
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
	
func _searching_signal() -> void:
	player.hud.status.text = "SEARCHING..."
	
func _on_dialogic_signal(argument: String):
	DialogueDone()
	match argument:
		"timeline-2":
			companion.companion_can_follow = true
			companion.animated_sprite_2d.flip_h = false
		"timeline-enemy-killed":
			title_card.visible = true
			title_card.showTitleCard("Object-Oriented Programming Concepts")
			await get_tree().create_timer(3).timeout 
			title_card.visible = false
		"timeline-miniboss":
			$CanActivatePlatforms/GateDoor4.deactivate()
			camera_2d.global_position = $CanActivatePlatforms/GateDoor4.global_position
			await get_tree().create_timer(2).timeout
			camera_2d.global_position = camera_pos.global_position

func _on_player_dead() -> void:
	player._reset_player(checkpoint)
	
func _on_enemy_dead(name: String) -> void:
	if name == "Monster": # first enemy encountered
		await get_tree().create_timer(1).timeout
		showDialogue("timeline-enemy-killed")
	
	elif name == "MiniBoss":
		await get_tree().create_timer(1).timeout
		$CanActivatePlatforms/GateDoor6.activate()
		camera_2d.global_position = $CanActivatePlatforms/GateDoor6.global_position
		await get_tree().create_timer(2).timeout
		camera_2d.global_position = camera_pos.global_position
		showDialogue("timeline-game-end")
		
	elif name == "BatEyes-Explained":
		await get_tree().create_timer(1).timeout
		showDialogue("timeline-enemy-weak")
		
func _on_ladder_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player.canClimbLadder = true

func _on_ladder_area_body_exited(body: Node2D) -> void:
	if body is Player:
		player.canClimbLadder = false
		player.toggle_gravity = false
		player.can_use_controls = true

func _on_check_points_body_entered(body: Node2D) -> void:
	if body is Player:
		checkpoint = body.global_position
		gs.write_savegame(self)

func _on_gravity_room_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player.canClimbLadder = true


func _on_gravity_room_area_body_exited(body: Node2D) -> void:
	if body is Player:
		player.canClimbLadder = false
		player.toggle_gravity = false
		player.can_use_controls = true


func _on_dead_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		player._reset_player(checkpoint)
	if body is EnemyBase:
		body.queue_free()


func _on_level_end_body_entered(body: Node2D) -> void:
	if body is Player:
		title_card.showTitleCard("Thank you for playing!")
		gs.reset_game_save()
		Engine.time_scale = 0.1
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://Game/Menu/Menu.tscn")
		
# Dialogue Signals

func _on_player_introduction_body_entered(body: Node2D) -> void:
	if body is Player:
		$CinematicAreas/PlayerIntroduction.disconnect("body_entered", _on_player_introduction_body_entered)
		zoom_camera(Vector2(3,3), 0.3)
		await get_tree().create_timer(1).timeout
		title_card.visible = true
		title_card.showTitleCard("Introduction")
		await get_tree().create_timer(1).timeout
		title_card.visible = false
		showDialogue("timeline-1")

func _on_companion_introduction_body_entered(body: Node2D) -> void:
	if body is Player:
		$CinematicAreas/CompanionIntroduction.disconnect("body_entered", _on_companion_introduction_body_entered)
		showDialogue("timeline-2")
		
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
		
func _on_short_range_terminal_body_entered(body: Node2D) -> void:
	if body is Player:
		$CinematicAreas/ShortRangeTerminal.disconnect("body_entered", _on_short_range_terminal_body_entered)
		body.short_range_terminal.usable = true # makes it accessible to the player
		showDialogue("timeline-short-range")
	
func _on_mini_boss_introduction_body_entered(body: Node2D) -> void:
	if body is Player:
		$CinematicAreas/MiniBossIntroduction.disconnect("body_entered",_on_mini_boss_introduction_body_entered )
		camera_2d.global_position = $EnemyGroup/MiniBoss.global_position
		await get_tree().create_timer(2).timeout
		camera_2d.global_position = camera_pos.global_position
		showDialogue("timeline-miniboss")

func _on_platform_explained_body_entered(body: Node2D) -> void:
	if body is Player:
		$CinematicAreas/PlatformExplained.disconnect("body_entered", _on_platform_explained_body_entered)
		showDialogue("timeline-platform-oop")
		
func _on_duplication_enemy_area_body_entered(body: Node2D) -> void:
	if body is Player:
		$CinematicAreas/DuplicationEnemyArea.disconnect("body_entered", _on_duplication_enemy_area_body_entered)
		showDialogue("timeline-duplicate")
		companion.hasPermissionToShoot = true

func _on_ncp_explained_body_entered(body: Node2D) -> void:
	if body is Player:
		$CinematicAreas/NCPExplained.disconnect("body_entered", _on_ncp_explained_body_entered)
		player.hud.visible = false
		player.can_use_controls = false
		await get_tree().create_timer(1).timeout
		camera_2d.global_position = $NPCs/FerretNPC.global_position
		await get_tree().create_timer(3).timeout
		player.hud.visible = true
		player.can_use_controls = true
		camera_2d.global_position = camera_pos.global_position
		showDialogue("timeline-npc-oop")
		
func _on_slow_down_enemy_body_entered(body: Node2D) -> void:
	if body is Player:
		$CinematicAreas/SlowDownEnemy.disconnect("body_entered", _on_slow_down_enemy_body_entered)
		showDialogue("timeline-enemy-slowtime")

func _on_quiet_enemy_body_entered(body: Node2D) -> void:
	if body is Player:
		$CinematicAreas/QuietEnemy.disconnect("body_entered", _on_quiet_enemy_body_entered)
		showDialogue("timeline-enemy-yellow")
