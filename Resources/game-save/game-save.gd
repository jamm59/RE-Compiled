class_name GameStateSave

const SAVE_GAME_PATH: String = "user://game-save.cfg"  # Use `.cfg` for ConfigFile

func load_start_game() -> bool:
	var config = ConfigFile.new()
	var result = config.load(SAVE_GAME_PATH)
	if result != OK:
		print("Failed to load game state in load_start_game. Error code:", result)
		return true
	return config.get_value("Game", "start_new_game", true)
	
# Save the game state to a ConfigFile
func write_savegame(body: Game) -> void:
	var config = ConfigFile.new()
	
	# Companion data
	config.set_value("Companion", "can_follow", body.companion.companion_can_follow)
	config.set_value("Companion", "activate_controls", body.companion.activate_companion_controls)
	config.set_value("Companion", "has_permission_to_shoot", body.companion.hasPermissionToShoot)
	
	# Player data
	config.set_value("Player", "health", body.player.health)
	config.set_value("Player", "coins", body.player.coins)
	config.set_value("Player", "can_use_controls", body.player.can_use_controls)
	config.set_value("Player", "can_use_short_range_terminal", body.player.short_range_terminal.usable)
	config.set_value("Player", "checkpoint_location", body.player.global_position)
	
	# Game state
	config.set_value("Game", "start_new_game", false)
	
	# Save to file
	var result = config.save(SAVE_GAME_PATH)
	if result != OK:
		print("Failed to save game state. Error code:", result)
	else:
		print("Game saved successfully to", SAVE_GAME_PATH)

# Load the game state from a ConfigFile
func load_savegame(body: Game) -> void:
	var config = ConfigFile.new()
	var result = config.load(SAVE_GAME_PATH)
	
	if result != OK:
		print("Failed to load game state. Error code:", result)
		return

	# Companion data
	body.companion.companion_can_follow = config.get_value("Companion", "can_follow", false)
	body.companion.activate_companion_controls = config.get_value("Companion", "activate_controls", false)
	body.companion.hasPermissionToShoot = config.get_value("Companion", "has_permission_to_shoot", false)
	
	# Player data
	body.player.health = config.get_value("Player", "health", 0.0)
	body.player.coins = config.get_value("Player", "coins", 0.0)
	body.player.can_use_controls = config.get_value("Player", "can_use_controls", false)
	body.player.short_range_terminal.usable = config.get_value("Player", "can_use_short_range_terminal", false)
	body.player.global_position = config.get_value("Player", "checkpoint_location", Vector2(-3313.0, 208.0))
	
	print("Game state loaded successfully from", SAVE_GAME_PATH)

func reset_game_save() -> void:
	var config = ConfigFile.new()

	# Companion defaults
	config.set_value("Companion", "can_follow", false)
	config.set_value("Companion", "activate_controls", false)
	config.set_value("Companion", "has_permission_to_shoot", false)

	# Player defaults
	config.set_value("Player", "health", 0.0)
	config.set_value("Player", "coins", 0.0)
	config.set_value("Player", "can_use_controls", false)
	config.set_value("Player", "can_use_short_range_terminal", false)
	config.set_value("Player", "checkpoint_location", Vector2(-3313.0, 208.0))

	# Game state defaults
	config.set_value("Game", "start_new_game", true)

	var result = config.save(SAVE_GAME_PATH)
	if result != OK:
		print("Failed to save reset state. Error code:", result)
	else:
		print("Game state reset and saved successfully.")
