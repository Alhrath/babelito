extends "../entity.gd"

func _input(event):
	if is_on_floor () and event.is_action_pressed("ui_up"):
		do_jump()

func _physics_process(delta):
	if  Input.is_action_pressed("ui_left"):
		move_left()
	
	elif Input.is_action_pressed("ui_right"):
		move_right()
		
	else :
		no_move()
