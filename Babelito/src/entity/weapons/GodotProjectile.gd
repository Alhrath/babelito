extends KinematicBody2D

#const THROW_VELOCITY = Vector2(800, -500)
export var THROW_VELOCITY = Vector2(800, -500)

var velocity = Vector2.ZERO


func _ready():
	set_physics_process(false)
					
func _physics_process(delta):
	velocity.y += Globals.gravity * delta
	var collision = move_and_collide(velocity * delta)
	if collision != null:
		_on_impact(collision.normal)

func launch(_direction):#with (direction)
	var temp = global_transform
	var scene = get_tree().current_scene
	get_parent().remove_child(self)
	scene.add_child(self)
	global_transform = temp
	
	velocity = Vector2(THROW_VELOCITY.x * Globals.playerfacing, THROW_VELOCITY.y)
	
	#velocity = Vector2(THROW_VELOCITY.x * Globals.facing, THROW_VELOCITY.y)
	#velocity = THROW_VELOCITY * Vector2(direction, 1)
	set_physics_process(true)
	
func _on_impact(normal : Vector2):
	velocity = velocity.bounce(normal)
	velocity *= 0.5 + rand_range(-0.05, 0.05)


