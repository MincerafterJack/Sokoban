extends PanelContainer

var is_fatal:bool = false


func set_error_message(msg:String, fatal:bool) -> void:
	$MarginContainer/VBoxContainer/ErrorMessage.text = msg
	is_fatal = fatal


func _on_ok_pressed():
	if is_fatal:
		get_tree().change_scene_to_file("res://internal/scenes/title/title.tscn")
	else:
		get_node(get_path()).queue_free()
