extends Resource
class_name PlayerSave

const SAVE_GAME_PATH: String = "res://Resources/game-save/player-save.gd"

@export var player: String = ""
@export var current_health: float = 0.0
@export var checkpointLocation: Vector2 = Vector2(0,0)


func write_playerstate(body: Player) -> void:
	player = body.previousAnimation
	current_health = body.health
	checkpointLocation = body.global_position
	#canUseShortRangeTerminal = body.
	ResourceSaver.save(self, SAVE_GAME_PATH)

static func load_playerstate() -> Resource:
	if ResourceLoader.exists(SAVE_GAME_PATH):
		return ResourceLoader.load(SAVE_GAME_PATH)
	return null
