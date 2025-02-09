extends PanelContainer


func _on_quit_pressed():
	get_tree().change_scene_to_file("res://internal/scenes/title/title.tscn")


func _on_no_pressed():
	get_node(get_path()).queue_free()
