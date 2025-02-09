extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.path = ""
	
	if not FileAccess.file_exists(Global.DEFAULT_PATH):
		$PanelContainer/MarginContainer/VBoxContainer/StartClassic.disabled = true
		$PanelContainer/MarginContainer/VBoxContainer/ClassicWarning.show()


func _on_start_classic_pressed():
	Global.path = Global.DEFAULT_PATH
	get_tree().change_scene_to_file("res://internal/scenes/gameplay/gameplay.tscn")


func _on_start_custom_pressed():
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
		get_tree().change_scene_to_file("res://internal/scenes/gameplay/gameplay.tscn")


func _on_level_editor_pressed():
	get_tree().change_scene_to_file("res://internal/scenes/level_editor/level_editor.tscn")


func _on_controls_pressed():
	get_tree().change_scene_to_file("res://internal/scenes/controls/game.tscn")


func _on_quit_pressed():
	get_tree().quit()
