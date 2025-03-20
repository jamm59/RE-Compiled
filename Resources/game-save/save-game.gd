class_name SaveGame
extends Resource

const SAVE_GAME_PATH: String = "res://Resources/game-save/save-game.gd"


func write_savegame() -> void:
	ResourceSaver.save(self, SAVE_GAME_PATH)

static func load_savegame() -> Resource:
	if ResourceLoader.exists(SAVE_GAME_PATH):
		return ResourceLoader.load(SAVE_GAME_PATH)
	return null
