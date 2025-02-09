extends TileMap

enum TileIndex {
	FLOOR = 0,
	WALL = 1,
	TARGET = 2,
	CRATE = 3,
	PLAYER = 4,
	ERASE = 5,
}

var current_level:int = 0
var current_tile:int

var ground_layers:Array[int] = []
var stuff_layers:Array[int] = []

var dragging:bool = false
var quick_erasing:bool = false
var first_click:bool = true
var prev_mouse_pos:Vector2

# Statistics.
static var target_count:int
static var crate_count:int
static var player_count:int

@onready var level_spinbox = get_node("%LevelSelection")


func _ready():
	clear()
	add_layer(current_level + 1)
	
	for i in get_layers_count():
		set_layer_enabled(i, false)
	
	ground_layers.append(0)
	set_layer_enabled(0, true)
	stuff_layers.append(1)
	set_layer_enabled(1, true)
	
	level_spinbox.value = 1.0


func _input(event):
	var pos:Vector2i = local_to_map(get_local_mouse_position())
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not dragging and event.pressed:
				dragging = true
			if dragging and not event.pressed:
				dragging = false
		
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if not quick_erasing and event.pressed:
				quick_erasing = true
			if quick_erasing and not event.pressed:
				quick_erasing = false
		
		draw_tile(pos, pos)
	
	elif event is InputEventMouseMotion:
		draw_tile(local_to_map(prev_mouse_pos), pos)
		update_statistics()


func draw_tile(a:Vector2i, b:Vector2i):
	var gnd_to_draw:Vector2i
	var stf_to_draw:Vector2i
	if dragging:
		if not quick_erasing:
			match current_tile:
				TileIndex.FLOOR:
					gnd_to_draw = Tile.FLOOR
					stf_to_draw = Tile.NONE
				
				TileIndex.WALL:
					gnd_to_draw = Tile.NONE
					stf_to_draw = Tile.WALL
				
				TileIndex.TARGET:
					gnd_to_draw = Tile.TARGET
					stf_to_draw = Tile.NONE
				
				TileIndex.CRATE:
					gnd_to_draw = Tile.DO_NOT_DRAW
					stf_to_draw = Tile.CRATE
				
				TileIndex.PLAYER:
					gnd_to_draw = Tile.DO_NOT_DRAW
					stf_to_draw = Tile.PLAYER_DOWN
				
				TileIndex.ERASE:
					gnd_to_draw = Tile.NONE
					stf_to_draw = Tile.NONE
		
		elif quick_erasing:
			gnd_to_draw = Tile.NONE
			stf_to_draw = Tile.NONE
		
		var start:Vector2i = a
		var	end:Vector2i = b
		
		if first_click:
			start = local_to_map(get_local_mouse_position())
			first_click = false
		
		if start == end:
			if gnd_to_draw != Tile.DO_NOT_DRAW:
				set_cell(ground_layers[current_level], start, 0, gnd_to_draw)
				
			if stf_to_draw != Tile.DO_NOT_DRAW:
				set_cell(stuff_layers[current_level], end, 0, stf_to_draw)
		else:
			for i:Vector2i in interpolated_line(start, end):
				if gnd_to_draw != Tile.DO_NOT_DRAW:
					set_cell(ground_layers[current_level], i, 0, gnd_to_draw)
				
				if stf_to_draw != Tile.DO_NOT_DRAW:
					set_cell(stuff_layers[current_level], i, 0, stf_to_draw)
		prev_mouse_pos = get_local_mouse_position()


func update_statistics():
	var players:int = \
			( get_used_cells_by_id(stuff_layers[current_level], 0, Tile.PLAYER_DOWN)\
			+ get_used_cells_by_id(stuff_layers[current_level], 0, Tile.PLAYER_UP)\
			+ get_used_cells_by_id(stuff_layers[current_level], 0, Tile.PLAYER_LEFT)\
			+ get_used_cells_by_id(stuff_layers[current_level], 0, Tile.PLAYER_RIGHT) ).size()
	
	target_count = get_used_cells_by_id(ground_layers[current_level], 0, Tile.TARGET).size()
	crate_count = get_used_cells_by_id(stuff_layers[current_level], 0, Tile.CRATE).size()
	player_count = players


func get_level_rect() -> Rect2i:
	var ground_tiles:Array[Vector2i] = get_used_cells(ground_layers[current_level])
	var stuff_tiles:Array[Vector2i] = get_used_cells(stuff_layers[current_level])
	var gnd_rect:Rect2i = Rect2i()
	var stf_rect:Rect2i = Rect2i()
	
	if ground_tiles:
		ground_tiles.sort_custom(func(a,b): return a.x < b.x)
		var gnd_pos_x:int = ground_tiles.front().x
		var gnd_end_x:int = ground_tiles.back().x
		ground_tiles.sort_custom(func(a,b): return a.y < b.y)
		var gnd_pos_y:int = ground_tiles.front().y
		var gnd_end_y:int = ground_tiles.back().y
		
		var gnd_pos:Vector2i = Vector2i(gnd_pos_x, gnd_pos_y)
		var gnd_end:Vector2i = Vector2i(gnd_end_x, gnd_end_y)
		gnd_rect = Rect2i(gnd_pos, gnd_end - gnd_pos)
		
	if stuff_tiles:
		stuff_tiles.sort_custom(func(a,b): return a.x < b.x)
		var stf_pos_x:int = stuff_tiles.front().x
		var stf_end_x:int = stuff_tiles.back().x
		stuff_tiles.sort_custom(func(a,b): return a.y < b.y)
		var stf_pos_y:int = stuff_tiles.front().y
		var stf_end_y:int = stuff_tiles.back().y
		
		var stf_pos:Vector2i = Vector2i(stf_pos_x, stf_pos_y)
		var stf_end:Vector2i = Vector2i(stf_end_x, stf_end_y)
		stf_rect = Rect2i(stf_pos, stf_end - stf_pos)
		
	if gnd_rect.get_area() > stf_rect.get_area():
		return gnd_rect
	else:
		return stf_rect


func throw_error(msg:String, fatal:bool) -> void:
	var popup:Node = Global.error_popup.instantiate()
	popup.set_error_message(msg, fatal)
	get_node("/root/CanvasLayer").add_child(popup)


func _on_item_list_item_selected(index:int):
	current_tile = index


func _on_spin_box_value_changed(unhandled_value:float):
	var value:int = (unhandled_value - 1) * 2 as int
	
	if get_layers_count() <= value:
		add_layer(value)
		ground_layers.append(value)
		add_layer(value + 1)
		stuff_layers.append(value + 1)
		
	current_level = unhandled_value - 1 as int
	for i in get_layers_count():
		set_layer_enabled(i, false)
	
	set_layer_enabled(ground_layers[current_level], true)
	set_layer_enabled(stuff_layers[current_level], true)


func _on_load_pressed():
	DisplayServer.file_dialog_show(\
			"Select file...",\
			"./",\
			"",\
			false,\
			DisplayServer.FILE_DIALOG_MODE_OPEN_FILE,\
			["*.skb ; Sokoban Levels"],\
			skb_file_handler
			)

func skb_file_handler(status:bool, selected_paths:PackedStringArray, selected_filter_index:int):
	if status:
		Global.path = selected_paths[0]
		
		if not FileAccess.file_exists(Global.path):
			throw_error("Non-existent level file.", true)
			return
	
		var file = FileAccess.open(Global.path, FileAccess.READ)
		file.seek(0)
		
		current_level = 0
		ground_layers.clear()
		stuff_layers.clear()
		clear()
		for i in range(get_layers_count() - 1, -1, -1):
			remove_layer(i)
		
		while file.get_position() < file.get_length():
			if typeof(file.get_var()) == TYPE_STRING:
				var ground_vertification = file.get_var()
				var stuff_vertification = file.get_var()
				var ground_data:Dictionary
				var stuff_data:Dictionary
				
				#region Verification
				if typeof(ground_vertification) == TYPE_DICTIONARY:
					ground_data = ground_vertification
				else:
					throw_error("Ground tiles are not in a proper format.", true)
					return
					
				if typeof(stuff_vertification) == TYPE_DICTIONARY:
					stuff_data = stuff_vertification
				else:
					throw_error("Stuff tiles are not in a proper format.", true)
					return
				#endregion
				
				add_layer(2 * current_level)
				ground_layers.append(2 * current_level)
				add_layer(2 * current_level + 1)
				stuff_layers.append(2 * current_level + 1)
				
				for coords in ground_data:
					set_cell(ground_layers[current_level], coords, 0, ground_data[coords])
				for coords in stuff_data:
					set_cell(stuff_layers[current_level], coords, 0, stuff_data[coords])
				
				current_level += 1
		file.close()
		
		current_level = 0
		level_spinbox.value = 1.0
		
		for i in get_layers_count():
			set_layer_enabled(i, false)
		
		set_layer_enabled(ground_layers[current_level], true)
		set_layer_enabled(stuff_layers[current_level], true)


func _on_save_pressed():
	if Global.path:
		export(FileAccess.file_exists(Global.path), [Global.path], 0)
	else:
		DisplayServer.file_dialog_show(\
				"Save file to...",\
				"./",\
				"",\
				false,\
				DisplayServer.FILE_DIALOG_MODE_SAVE_FILE,\
				["*.skb ; Sokoban Levels"],\
				export
				)


func _on_save_as_pressed():
	DisplayServer.file_dialog_show(\
			"Save file to...",\
			"./",\
			"",\
			false,\
			DisplayServer.FILE_DIALOG_MODE_SAVE_FILE,\
			["*.skb ; Sokoban Levels"],\
			export
			)


func export(status:bool, selected_paths:PackedStringArray, selected_filter_index:int):
	if status:
		Global.path = selected_paths[0]
		
		if not Global.path.to_lower().ends_with(".skb"):
			Global.path += ".skb"
		
		var file = FileAccess.open(Global.path, FileAccess.WRITE)
		
		for i in get_layers_count():
			var selected_tiles:Dictionary = {}
			for coords in get_used_cells(i):
				selected_tiles[coords] = get_cell_atlas_coords(i, coords)
			#for coords in get_used_cells(i + 1):
				#stuff_tiles[coords] = get_cell_atlas_coords(Tile.STUFF_LAYER, coords)
			if i % 2 == 0:
				file.store_var("sokoban")
			file.store_var(selected_tiles)
		file.close()
	
	else:
		throw_error("File unavaliable.", false)


func interpolated_line(p0:Vector2, p1:Vector2):
	var points = []
	var d = p1 - p0
	var N = max(abs(d.x), abs(d.y))
	for i in N + 1:
		var t = float(i) / float(N)
		var point = Vector2(round(lerp(p0.x, p1.x, t)), round(lerp(p0.y, p1.y, t)))
		points.append(point)
	return points


func _on_quit_pressed():
	var popup:Node = Global.quit_confirmation.instantiate()
	get_node("/root/CanvasLayer").add_child(popup)


func _on_help_pressed():
	var popup:Node = Global.editor_help.instantiate()
	get_node("/root/CanvasLayer").add_child(popup)
