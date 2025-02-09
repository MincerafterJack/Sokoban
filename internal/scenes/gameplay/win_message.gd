extends PanelContainer

signal next_level


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


func _on_tile_map_puzzle_completed(level:int, total:int, steps:int):
	get_tree().paused = true
	show()
	if level > total - 1:
		$MarginContainer/VBoxContainer/Label.text\
				= "Level %d finished in %d steps. \n Level pack completed." % [level, steps]
	else:
		$MarginContainer/VBoxContainer/Label.text\
				= "Level %d finished in %d steps." % [level, steps]


func _on_continue_pressed():
	get_tree().paused = false
	hide()
	next_level.emit()
