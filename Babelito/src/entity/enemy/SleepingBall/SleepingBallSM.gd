extends "res://src/engine/singleton/StateMachine.gd"


func _ready():
	add_state("sleep")
	add_state("chase")
	add_state("attack")
	call_deferred("set_state", states.sleep)

func _state_logic(delta):
	parent._apply_gravity(delta)
	parent._apply_movement()
	
	if state != states.attack && parent._should_turn():
		parent.turn()

	if state == states.chase:
		parent._chase_player()
	else:
		parent._stop()

	parent._apply_velocity()
	
func _get_transition(_delta):
	match state:
		states.sleep:
			if parent._should_chase():
				return states.chase
				
		states.chase:
			if parent._should_sleep():
				return states.sleep
			elif parent._should_attack():
				return states.attack
				
		states.attack:
			if parent.is_on_floor():
				return states.sleep
	
	return null

func _enter_state(_new_state, _old_state):
	parent.get_node("StateLabel").text = states.keys()[_new_state].capitalize()
	match _new_state:
		states.sleep:
			parent.anim_sb.play("rest")
		states.chase:
			parent.anim_sb.play("chase")
		states.attack:
			parent.anim_sb.play("attack")
			parent.attack()

func _exit_state(_old_state, _new_state):
	pass
##########################################
func _on_DetectionArea_area_entered(_area):
	parent._physics_process(true) # Replace with function body.

func _on_DetectionArea_area_exited(_area):
	parent._physics_process(false)
