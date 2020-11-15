extends "../enemy.gd"

var hunting_table = []

func _init():
	jump_force = 150
	acceleration = 25
	ai_wait_time = 0.1
	is_from_time_moon = true

func ai_loop():
	if hunting_table.empty():
		idle()
	else:
		hunt_preys()

func _on_vitalzone_body_entered(body):
	if(body.is_from_time_moon == false):
		if(!hunting_table.has(body)):
			hunting_table.insert(body.name, body)

func idle():
	var ai_decision = randi()%3+1
	match ai_decision:
		1:
			move_left()
		2:
			move_right()
		3:
			jump()

func hunt_preys():
	if(hunting_table.size() == 1):
		hunt_prey(hunting_table[0])
	else:
		jump()

func hunt_prey(prey):
	if(prey.global_position.y > global_position.y):
		if (prey.global_position.x < global_position.x):
			move_left()
		else:
			move_right()
	else:
		jump()
