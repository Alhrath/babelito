extends "../engine/gravity.gd"

var JUMP_MAX = 10
var JUMP_FORCE = 250
var ACCELERATION = 175
var DECELERATION = 0.1

var jump_count = 0
	

func _input(event):
	if jump_count < JUMP_MAX and event.is_action_pressed("ui_up"):
		motion.y = -JUMP_FORCE
		jump_count += 1
	if is_on_floor ():
		jump_count = 0

func _physics_process(delta):
	
	
	
	if  Input.is_action_pressed("ui_left"):
		motion.x = -(ACCELERATION)
	
	elif Input.is_action_pressed("ui_right"):
		motion.x = (ACCELERATION)
		
	else :
		motion.x = lerp(motion.x, 0, DECELERATION)
		

	move_and_slide(motion,globals.UP)
