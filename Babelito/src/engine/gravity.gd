extends KinematicBody2D

var GRAVITY = 16
var MAXFALLSPEED = 900 

var motion = Vector2()

func _physics_process(delta):
	
	motion.y += GRAVITY
	
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED
	
	move_and_slide(motion,globals.UP)
