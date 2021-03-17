extends Control

const SAVE_DIR = "user://saves/"

onready var console_label = $CanvasLayer/Control/Save_load_window/Panel/VBoxContainer/CenterContainer/NinePatchRect/Label

var save_path = SAVE_DIR + "save.dat"

func _input(event):
	if event.is_action_pressed("menu"):
			get_tree().paused = not get_tree().paused
			visible = not visible


func _on_Save_button_pressed():
	
	var data = {
		"name" : "Pioupiou",
		"health" : 100,
		"number of ennemy slain" : "nullard"
	}
	
	var dir = Directory.new()
	if !dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)
	
	
	var file = File.new()
	var error = file.open_encrypted_with_pass(save_path, File.WRITE, "Parislatino")
	if error == OK:
		file.store_var(data)
		file.close()
		
	
	console_write("data_saved")
	pass
	
func _on_Load_button_pressed():
	
	var file = File.new()
	if file.file_exists(save_path):
		var error = file.open_encrypted_with_pass(save_path, File.READ, "Parislatino")
		if error == OK:
			var player_data = file.get_var()
			file.close()
	
			console_write(player_data)
	pass
	
func console_write(value):
	console_label.text += str(value) + "\n"
