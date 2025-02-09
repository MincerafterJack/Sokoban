extends PanelContainer


func _on_ok_pressed():
	get_node(get_path()).queue_free()
