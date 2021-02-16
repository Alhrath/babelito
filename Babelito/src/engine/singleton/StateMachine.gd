extends Node

class_name StateMachine

signal state_changed(new_state, old_state)

var state = null setget set_state
var previous_state = null
var states = {}

onready var parent = get_parent()


func _physics_process(delta):

	if state != null:
		_state_logic(delta)
		var transition = _get_transition(delta)
		if transition != null:
			set_state(transition)
			
func _state_logic(_delta):
	pass

func _get_transition(_delta):
	return null

func _enter_state(_new_state, _old_state):
	pass

func _exit_state(_old_state, _new_state):
	pass

func set_state(_new_state):
	previous_state = state
	state = _new_state
	
	
	if previous_state != null:
		_exit_state(previous_state, _new_state)
	if _new_state != null:
		_enter_state(_new_state, previous_state)
	
	emit_signal("state_changed", _new_state, previous_state)
	
func add_state(state_name):
	states[state_name] = states.size()
	
