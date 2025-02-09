extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	var file = FileAccess.open("./classic.skb", FileAccess.WRITE)
	
	for i in get_layers_count():
		var selected_tiles:Dictionary = {}
		for coords in get_used_cells(i):
			selected_tiles[coords] = get_cell_atlas_coords(i, coords)
		#for coords in get_used_cells(i + 1):
			#stuff_tiles[coords] = get_cell_atlas_coords(Tile.STUFF_LAYER, coords)
		if i % 2 == 0:
			file.store_var("sokoban")
		file.store_var(selected_tiles)
		#file.store_var(stuff_tiles)
		
	file.close()
	
	#region Printing the level data in console
	#print("Coords	Ground")
	#for coords in get_used_cells(Tile.GROUND_LAYER):
		#var tile_name:String = ""
		#match ground_tiles[coords]:
			#Tile.FLOOR:
				#tile_name = "Floor"
			#Tile.TARGET:
				#tile_name = "Target"
		#print(coords, "	", tile_name)
	#print()
	#print("Coords	Stuff")
	#for coords in get_used_cells(Tile.STUFF_LAYER):
		#var tile_name:String = ""
		#match stuff_tiles[coords]:
			#Tile.WALL:
				#tile_name = "Wall"
			#Tile.CRATE:
				#tile_name = "Crate"
			#Tile.PLAYER_DOWN:
				#tile_name = "Player Down"
			#Tile.PLAYER_RIGHT:
				#tile_name = "Player Right"
			#Tile.PLAYER_LEFT:
				#tile_name = "Player Left"
			#Tile.PLAYER_UP:
				#tile_name = "Player Up"
		#print(coords, "	", tile_name)
	#endregion
	
	#print(get_layers_count())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().quit()
