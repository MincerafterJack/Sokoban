extends TileMap

var current_level:int = 0
var total_levels:int = 0
var levels:Array[int] = []
var playable:bool = false

var player_dir:Vector2i
var player_positions:Array[Vector2i] = []
var history:Array[Dictionary] = []

signal game_paused
signal puzzle_completed


# Called when the node enters the scene tree for the first time.
func _ready():
	clear()
	
	# Generating a look-up table for level entries.
	if not FileAccess.file_exists(Global.path):
		throw_error("Non-existent level file.", true)
		return
	
	var file = FileAccess.open(Global.path, FileAccess.READ)
	file.seek(0)
	while file.get_position() < file.get_length():
		# HACK: Each entry starts with the string "sokoban".
		# and get_var() would get the string, leave the cursor behind the string,
		# and that's where the level data starts!
		# get_var() isn't type-safe, so it verifies the type instead.
		if typeof(file.get_var()) == TYPE_STRING:
			levels.append(file.get_position())
			total_levels += 1
	file.close()
	
	if total_levels < 1:
		throw_error("No levels in file.", true)
		return
	
	%LevelSelection.max_value = total_levels
	start_level(current_level)


func _input(event):
	if event.is_action_pressed("reset"):
		start_level(current_level)
	
	if event.is_action_pressed("movement_up"):
		try_move(Vector2i.UP)
	elif event.is_action_pressed("movement_down"):
		try_move(Vector2i.DOWN)
	elif event.is_action_pressed("movement_left"):
		try_move(Vector2i.LEFT)
	elif event.is_action_pressed("movement_right"):
		try_move(Vector2i.RIGHT)
	
	if event.is_action_pressed("undo"):
		undo()
	
	if event.is_action_pressed("pause"):
		game_paused.emit()


func start_level(level_number:int) -> void:
	clear()
	history.clear()
	
	if not FileAccess.file_exists(Global.path):
		throw_error("Non-existent level file.", true)
		return
	
	var ground_tiles:Dictionary = {}
	var stuff_tiles:Dictionary = {}
	
	var file = FileAccess.open(Global.path, FileAccess.READ)
	file.seek(levels[level_number])
	var ground_vertification = file.get_var()
	var stuff_vertification = file.get_var()
	file.close()
	
	if typeof(ground_vertification) == TYPE_DICTIONARY:
		ground_tiles = ground_vertification
	else:
		throw_error("Ground tiles are not in a proper format.", true)
		return
		
	if typeof(stuff_vertification) == TYPE_DICTIONARY:
		stuff_tiles = stuff_vertification
	else:
		throw_error("Stuff tiles are not in a proper format.", true)
		return
	
	for coords in ground_tiles:
		set_cell(Tile.GROUND_LAYER, coords, 0, ground_tiles[coords])
	for coords in stuff_tiles:
		set_cell(Tile.STUFF_LAYER, coords, 0, stuff_tiles[coords])
	
	if get_used_cells_by_id(Tile.GROUND_LAYER, 0, Tile.TARGET).size()\
			!= get_used_cells_by_id(Tile.STUFF_LAYER, 0, Tile.CRATE).size():
		throw_error("Target count does not match the crate count. \n Someone's package is missing, sad...", false)
	
	player_positions = \
			get_used_cells_by_id(Tile.STUFF_LAYER, 0, Tile.PLAYER_DOWN)\
			+ get_used_cells_by_id(Tile.STUFF_LAYER, 0, Tile.PLAYER_UP)\
			+ get_used_cells_by_id(Tile.STUFF_LAYER, 0, Tile.PLAYER_LEFT)\
			+ get_used_cells_by_id(Tile.STUFF_LAYER, 0, Tile.PLAYER_RIGHT)


func try_move(dir:Vector2i) -> void:
	if dir.length_squared() > 1:
		throw_error("Invalid movement direction. \n What, some weird stunt moves?", false)
		return
	
	var current_playfield:Dictionary = {}
	for coords in get_used_cells(Tile.STUFF_LAYER):
		current_playfield[coords] = get_cell_atlas_coords(Tile.STUFF_LAYER, coords)
	if current_playfield != history.back():
		history.push_back(current_playfield)
	
	player_dir = dir
	player_positions.sort_custom(sort_player_positions)
	for player in player_positions:
		if get_cell_atlas_coords(Tile.STUFF_LAYER, player + dir) == Tile.NONE:
			set_cell(Tile.STUFF_LAYER, player, 0, Tile.NONE)
			set_cell(Tile.STUFF_LAYER, player + dir, 0, Tile.PLAYER_DIR[dir])
		
		elif get_cell_atlas_coords(Tile.STUFF_LAYER, player + dir) == Tile.CRATE:
			if get_cell_atlas_coords(Tile.STUFF_LAYER, player + 2 * dir) == Tile.NONE:
				set_cell(Tile.STUFF_LAYER, player, 0, Tile.NONE)
				set_cell(Tile.STUFF_LAYER, player + dir, 0, Tile.PLAYER_DIR[dir])
				set_cell(Tile.STUFF_LAYER, player + 2 * dir, 0, Tile.CRATE)
	
	player_positions = \
			get_used_cells_by_id(Tile.STUFF_LAYER, 0, Tile.PLAYER_DOWN)\
			+ get_used_cells_by_id(Tile.STUFF_LAYER, 0, Tile.PLAYER_UP)\
			+ get_used_cells_by_id(Tile.STUFF_LAYER, 0, Tile.PLAYER_LEFT)\
			+ get_used_cells_by_id(Tile.STUFF_LAYER, 0, Tile.PLAYER_RIGHT)
	
	check_win()

func sort_player_positions(a:Vector2i, b:Vector2i) -> bool:
	match player_dir:
		Vector2i.UP:
			return a.y < b.y
		Vector2i.DOWN:
			return a.y > b.y
		Vector2i.LEFT:
			return a.x < b.x
		Vector2i.RIGHT:
			return a.x > b.x
		_:
			return true


func undo() -> void:
	if history.size() <= 0:
		return
	
	var playfield:Dictionary = history.pop_back()
	clear_layer(Tile.STUFF_LAYER)
	for coords in playfield:
		set_cell(Tile.STUFF_LAYER, coords, 0, playfield[coords])
	
	player_positions = \
			get_used_cells_by_id(Tile.STUFF_LAYER, 0, Tile.PLAYER_DOWN)\
			+ get_used_cells_by_id(Tile.STUFF_LAYER, 0, Tile.PLAYER_UP)\
			+ get_used_cells_by_id(Tile.STUFF_LAYER, 0, Tile.PLAYER_LEFT)\
			+ get_used_cells_by_id(Tile.STUFF_LAYER, 0, Tile.PLAYER_RIGHT)


func check_win() -> void:
	var crates:Array[Vector2i] = get_used_cells_by_id(Tile.STUFF_LAYER, 0, Tile.CRATE)
	var targets:Array[Vector2i] = get_used_cells_by_id(Tile.GROUND_LAYER, 0, Tile.TARGET)
	
	crates.sort()
	targets.sort()
	
	if crates == targets:
		puzzle_completed.emit(current_level + 1, total_levels, history.size())


func throw_error(msg:String, fatal:bool) -> void:
	var popup:Node = Global.error_popup.instantiate()
	popup.set_error_message(msg, fatal)
	get_node("CanvasLayer").add_child(popup)


func _on_win_message_next_level():
	get_tree().paused = false
	if current_level + 1 > total_levels - 1:
		get_tree().change_scene_to_file("res://internal/scenes/title/title.tscn")
	else:
		current_level = clampi(current_level + 1, 0, total_levels - 1)
		start_level(current_level)


func _on_level_selection_value_changed(value:float):
	current_level = value - 1 as int
	start_level(current_level)
