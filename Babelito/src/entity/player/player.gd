extends "../entity.gd"

func _input(event):
	if is_on_floor () and event.is_action_pressed("jump"):
		jump()

func _physics_process(delta):
	if  Input.is_action_pressed("ui_left"):
		move_left()
	
	#permet de donner des différences de saut variable (si appuyé longtemps fait une certaine hauteur, si tap saute à une hauteur plus courte)
	if Input.is_action_just_released("jump") && motion.y < 0 :
		motion.y = 0
	
	elif Input.is_action_pressed("ui_right"):
		move_right()
		
	else :
		no_move()
