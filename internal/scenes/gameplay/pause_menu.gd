extends PanelContainer

var failsafe:bool = false


func _ready():
	hide()


func _process(delta):
	if Input.is_action_just_released("pause"):
		failsafe = true
	if Input.is_action_just_pressed("pause") and failsafe:
		resume()


func _on_game_paused():
	get_tree().paused = true
	show()


func _on_resume():
	resume()


func resume():
	hide()
	failsafe = false
	get_tree().paused = false


func _on_back_to_title_pressed():
	resume()
	get_tree().change_scene_to_file("res://internal/scenes/title/title.tscn")


func _on_exit_to_desktop_pressed():
	resume()
	get_tree().quit()
