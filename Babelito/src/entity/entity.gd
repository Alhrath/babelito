extends KinematicBody2D

var gravity = globals.GRAVITY
var maxfallspeed = globals.MAXFALLSPEED

var jump_force = globals.JUMP_FORCE
var acceleration = globals.ACCELERATION
var deceleration = globals.DECELERATION

var motion = Vector2()

func _physics_process(delta):
	
	# GRAVITY
	motion.y += gravity
	if motion.y > maxfallspeed:
		motion.y = maxfallspeed
	motion = move_and_slide(motion,globals.UP)

func do_jump():
	motion.y = -jump_force

func move_left():
	motion.x = -(acceleration)

func move_right():
	motion.x = (acceleration)

func no_move():
	motion.x = lerp(motion.x, 0, deceleration)
