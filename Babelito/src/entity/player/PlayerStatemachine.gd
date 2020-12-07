extends "res://src/engine/singleton/StateMachine.gd"

func _ready():

	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	add_state("throw_godot")
	################
	add_state("dead")
	###############3
	call_deferred("set_state", states.idle) #defining "idle" as default

func _state_logic(delta):
	parent._handle_move_input()
	parent._apply_gravity(delta)
	parent._apply_movement()
	
func _input(event): 
	if state == states.idle || state == states.run:
		if event.is_action_pressed("throw"):
			set_state(states.throw_godot)
		
		if event.is_action_pressed("jump"): 
		
			if Input.is_action_pressed("down"):
				if parent._check_is_grounded(parent.drop_thru_raycasts):
					parent.set_collision_mask_bit(parent.DROP_THRU_BIT, false)
					
			else:
				parent.velocity.y = Globals.max_jump_velocity
				parent.is_jumping = true

	if state == states.jump:
		if event.is_action_released("jump") && parent.velocity.y < Globals.min_jump_velocity:
			parent.velocity.y = Globals.min_jump_velocity
		if event.is_action_pressed("throw"):
			set_state(states.throw_godot)
			

func _get_transition(delta):
	match state:
		states.idle:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif parent.velocity.x != 0:
				return states.run
				
		states.run:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif parent.velocity.x == 0:
				return states.idle
		
		states.jump:
			if parent.is_on_floor():
				return states.idle
			elif parent.velocity.y >= 0:
				return states.fall
				
		states.fall:
			if parent.is_on_floor():
				return states.idle
			elif parent.velocity.y < 0:
				return states.jump
				
		states.throw_godot:
			if parent.held_item == null:
				if parent.is_on_floor():
					if parent.velocity.x != 0:
						return states.run
					else:
						return states.idle
				elif parent.velocity.y < 0:
					return states.jump
				else: 
					return states.fall
			else:
				return states.throw_godot
		states.dead:
			_physics_process(false)

	return null

func _enter_state(new_state, old_state):
	parent.get_node("StateLabel").text = states.keys()[new_state].capitalize()
	match new_state:
		states.idle:
			parent.anim_player.play("idle")
			
		states.run:
			parent.anim_player.play("run")

		states.jump:
			parent.anim_player.play("jump")
			
		states.fall:
			parent.anim_player.play("fall")
			
		states.throw_godot:
			parent.velocity = Vector2.ZERO
			parent.anim_player.play("throw", 0)
			parent.spawn_godot()

func _exit_state(old_state, new_state):
	pass
