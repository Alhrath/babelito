extends Node

var skill_data
var armor_data

func _ready():
	var skill_data_file = File.new()
	skill_data_file.open("res://SkillData - Sheet1.json", File.READ)
	var skill_data_json = JSON.parse(skill_data_file.get_as_text())
	skill_data_file.close()
	skill_data = skill_data_json.result
	
	var armor_data_file = File.new()
	armor_data_file.open("res://ArmorData - Sheet1.json", File.READ)
	var armor_data_json = JSON.parse(armor_data_file.get_as_text())
	armor_data_file.close()
	armor_data = armor_data_json.result
	
