extends "res://src/engine/singleton/StateMachine.gd"

const STOP_THRESHOLD = 32.0

func _ready():

	add_state("dashing")
	add_state("dodging")
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	add_state("throw_godot")
	add_state("wall_slide")
	add_state("dead")
	add_state("crouch")
	add_state("crawl")
	call_deferred("set_state", states.idle) #defining "idle" as default

func _state_logic(delta):
	parent._update_move_direction()
	parent._update_wall_direction()
	
	if [states.idle, states.run, states.jump, states.fall, states.dodging].has(state): #######without dodging
		parent._handle_movement()
		#to set which states can move
		
	elif [states.crouch, states.crawl].has(state):
		parent._handle_movement(parent.CRAWL_SPEED)
	#to set different speed when crawling
	
	if state == states.wall_slide:
		parent._cap_gravity_wall_slide()
		parent._handle_wall_slide_sticking()
		
	parent._apply_gravity(delta)	
	parent._apply_movement()
	
func _input(event): # == which state can do what 
	if [states.idle, states.run, states.crouch, states.crawl].has(state) && parent.can_stand(): 
	#for all these states:
		if event.is_action_pressed("throw"):
			set_state(states.throw_godot)
			
		elif event.is_action_pressed("jump"): 
			if Input.is_action_pressed("down"):
			#when jump + down are pressed ==> drop through platform
				if parent._check_is_grounded(parent.drop_thru_raycasts):
					parent.set_collision_mask_bit(parent.DROP_THRU_BIT, false)
			else:
				parent.jump()
	
		elif event.is_action_pressed("dodge") && parent.dodging_timer.is_stopped():
			set_state(states.dodging)
	#####################################################
#		elif Input.is_action_pressed("down"):
#			if Input.is_action_pressed("move_left"):
#				set_state("dashing")
#			elif Input.is_action_pressed("move_right"):
#				set_state("dashing")
	#####################################################
				
	elif state == states.wall_slide:
		if event.is_action_pressed("jump"):
			parent.wall_jump()
			set_state(states.jump)

	elif state == states.jump:
		if event.is_action_released("jump"):
			parent.variable_jump()#variation in jump intensity
			
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
			elif Input.is_action_pressed("down"):
				return states.crouch
			elif Input.is_action_pressed("dodge"):
				return states.dodging

		states.run:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif parent.velocity.x == 0:
				return states.idle
			elif Input.is_action_pressed("down"):
				return states.crawl
			elif Input.is_action_pressed("dodge"):
				return states.dodging

		states.jump:
			if parent.wall_direction != 0 && parent.wall_slide_cooldown.is_stopped():
				return states.wall_slide
			elif parent.is_on_floor(): 
				return states.idle
			elif parent.velocity.y >= 0:
				return states.fall
			elif Input.is_action_pressed("dodge"):
				return states.dodging

		states.fall:
			if parent.wall_direction != 0 && parent.wall_slide_cooldown.is_stopped():
				return states.wall_slide
			elif parent.is_on_floor(): 
				return states.idle
			elif parent.velocity.y < 0:
				return states.jump
			elif Input.is_action_pressed("dodge"):
				return states.dodging

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
		
		states.wall_slide:
			if parent.is_on_floor():
				return states.idle
			elif parent.wall_direction == 0:
				return states.fall
				
		states.crouch:
			if !Input.is_action_pressed("down") && parent.can_stand():
				return states.idle
			elif !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				else:
					return states.fall
			elif abs(parent.velocity.x) >= STOP_THRESHOLD:
				return states.crawl
				
		states.crawl:
			if !Input.is_action_pressed("down") && parent.can_stand():
				return states.run
			elif !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				else:
					return states.fall
			elif abs(parent.velocity.x) < STOP_THRESHOLD:
				return states.crouch

		states.dodging:
			if parent.dodging_timer.is_stopped():
				if !parent.is_on_floor():
					if parent.velocity.y < 0:
						return states.jump
					elif parent.velocity.y > 0:
						return states.fall
				elif parent.velocity.x == 0:
					return states.idle
				else:
					return states.run
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
		
		states.wall_slide:
			parent.anim_player.play("wall_slide")
			parent.body.scale.x = -parent.wall_direction
			
		states.crouch:
			parent.anim_player.play("crouch")
			if old_state != states.crawl:
				parent._on_crouch()
				
		states.crawl:
			parent.anim_player.play("crawl")
			if old_state != states.crouch:
				parent._on_crouch()
				
		states.dodging:
			parent.anim_player.play("dodge")
			parent.dodging_timer.start()
		
func _exit_state(old_state, new_state):
	match old_state:
		states.wall_slide:
			parent.wall_slide_cooldown.start()

		states.crouch:
			if new_state != states.crawl:
				parent._on_stand()
		
		states.crawl:
			if new_state != states.crouch:
				parent._on_stand()

func is_crouched():
	return [states.crouch, states.crawl].has(state)

func _on_WallSlideStickyTimer_timeout():
	if state == states.wall_slide:
		set_state(states.fall)	

