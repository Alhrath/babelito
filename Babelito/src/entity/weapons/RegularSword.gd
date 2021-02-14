extends KinematicBody2D

#const THROW_VELOCITY = Vector2(800, -500)
export var THROW_VELOCITY = Vector2(800, -500)

var velocity = Vector2.ZERO


func launch(_direction):#with (direction)
	var temp = global_transform
	var scene = get_tree().current_scene
	get_parent().remove_child(self)
	scene.add_child(self)
	global_transform = temp
	
	velocity = Vector2(Globals.playerfacing, 0) 




func _on_DamageArea_area_entered(area):
	pass # Replace with function body.
