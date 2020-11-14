extends "../enemy.gd"


func _init():
	jump_force = 150
	acceleration = 25
	ai_wait_time = 0.1

func ai_loop():
	var ai_decision = randi()%3+1
	
	match ai_decision:
		1:
			move_left()
		2:
			move_right()
		3:
			jump()
