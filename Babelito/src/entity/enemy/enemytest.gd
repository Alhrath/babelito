extends "res://src/engine/singleton/statemachine.gd"

func _ready():
	add_state("sleep")
	add_state("chase")
	add_state("attack")
	call_deferred("set_state", states.sleep)

func _state_logic(delta):
	parent._apply_gravity(delta)
	
	if state != states.attack && parent._should_turn():
		parent._turn()
		
	if state == states.chase:
		parent._chase_player()
	else:
		parent._stop()
	
	parent._apply_velocity()
	
	
func _get_transition(delta):
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
	
func _enter_state(new_state, old_state):
	match new_state:
		states.sleep:
			parent.animation_play("rest")
		states.chase:
			parent.animation_play("chase")
		states.attack:
			parent.animation_play("attack")
			parent.attack()

func _exit_state(old_state, new_state):
	pass
