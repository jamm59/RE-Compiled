extends Resource
class_name PlayerSave

const SAVE_GAME_PATH: String = "res://Resources/game-save/player-save.gd"

@export var health: float = 0.0
@export var can_use_short_range_termibal: bool = false
@export var checkpointLocation: Vector2 = Vector2(0,0)
@export var coins: float


func write_playerstate(body: Player) -> void:
	health = body.health
	coins = body.coins
	checkpointLocation = body.global_position
	can_use_short_range_termibal = body.short_range_terminal.usable
	ResourceSaver.save(self, SAVE_GAME_PATH)

static func load_playerstate() -> Resource:
	if ResourceLoader.exists(SAVE_GAME_PATH):
		return ResourceLoader.load(SAVE_GAME_PATH)
	return null
