extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


func _input(event):
	if event is InputEventMouseButton:
		if visible:
			hide()


func _on_level_statistics_pressed():
		
	var target_count:String = String.num_int64(%TileMap.target_count)
	var crate_count:String = String.num_int64(%TileMap.crate_count)
	var player_count:String = String.num_int64(%TileMap.player_count)
	var level_rect:Rect2i = %TileMap.get_level_rect()
	
	show()
	%LevelSize.text = "Level size: %dx%d" % [level_rect.size.x, level_rect.size.y]
	%LevelCenter.text = "Level center: (%d, %d)" % [level_rect.get_center().x, level_rect.get_center().y]
	%TargetCount.text = "Target count: " + target_count
	%CrateCount.text = "Crate count: " + crate_count
	%PlayerCount.text = "Player count: " + player_count
