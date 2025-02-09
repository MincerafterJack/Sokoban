extends PanelContainer


func _on_back_pressed():
	get_tree().change_scene_to_file("res://internal/scenes/title/title.tscn")
