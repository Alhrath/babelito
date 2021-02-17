extends KinematicBody2D

signal grounded_updated(is_grounded)

signal health_updated(health)
signal killed()

const GodotProjectile_PS = preload("res://src/entity/weapons/GodotProjectile.tscn")
const CRAWL_SPEED = 32 * 5 #=speed when crawling
const SLOPE_STOP_THRESHOLD = 64 #get better slope movements
const DROP_THRU_BIT = 1 # collision variable for dropping through platform
var WALL_JUMP_VELOCITY = Vector2(1,-2) * Globals.move_speed *1.5
## jump when wall-sliding

export (float) var max_health = 200
onready var health = max_health setget _set_health

var velocity = Vector2()
var move_speed = Globals.move_speed
var gravity 
var max_jump_velocity 
var min_jump_velocity 
var move_direction


var held_item = null
var is_jumping = false #useful to create platform drop through
var is_grounded = false #to permit a check_ground method associated with raycasts
var is_wall_sliding = false
var wall_direction = 1


onready var state_machine = $StateMachine
onready var standing_collision = $StandingShape
onready var crouching_collision = $CrouchingShape
onready var standing_hitbox = $Hitbox/StandingShape
onready var crouching_hitbox = $Hitbox/CrouchingShape
onready var left_wall_raycasts = $WallRaycasts/LeftWallRaycasts
onready var right_wall_raycasts = $WallRaycasts/RightWallRaycasts
onready var wall_slide_cooldown = $Timers/WallSlideCooldown
onready var wall_slide_sticky_timer = $Timers/WallSlideStickyTimer
onready var body = $Body
onready var drop_thru_raycasts = $DropThruRaycasts
onready var raycasts = $Raycasts
onready var anim_player = $Body/PlayerRig/AnimationPlayer
onready var held_item_position = $Body/PlayerRig/Torso/RightArm/HeldItemPosition
onready var hitbox = $Hitbox
onready var invulnerability_timer = $Timers/InvulnerabilityTimer
onready var effects_animation = $Body/PlayerRig/EffectsAnimation
onready var dodging_timer = $Timers/DodgingTimer
onready var dodging_cooldown = $Timers/DodgingCooldown
onready var dashing_timer = $Timers/DashingTimer
onready var dashing_cooldown = $Timers/DashingCooldown


func _ready():
	Globals.player = self
	

func _apply_gravity(delta):
	velocity.y += Globals.gravity * delta
	if is_wall_sliding:
		_cap_gravity_wall_slide()

func _update_move_direction():
	move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right")) 
#inputs for movement
	
func _cap_gravity_wall_slide():
	var max_velocity = 96 *2 if !Input.is_action_pressed("down") else 8*96 
#velocity/gravity when wall-sliding and acceleration if key "down" is pressed.
	velocity.y = min(velocity.y, max_velocity) 

func _apply_movement():

	if is_jumping && velocity.y >= 0:
		is_jumping = false
	
	var snap = Vector2.DOWN * 32 if !is_jumping else Vector2.ZERO
	
	if move_direction == 0 && abs(velocity.x) < SLOPE_STOP_THRESHOLD:
		velocity.x = 0
	var stop_on_slope = true if get_floor_velocity().x == 0 else false
	
	velocity = move_and_slide_with_snap(velocity, snap, Globals.UP, stop_on_slope)
	
	var was_grounded = is_grounded
	is_grounded = is_on_floor()  && get_collision_mask_bit(DROP_THRU_BIT) && _check_is_grounded() 
	
	if was_grounded == null || is_grounded != was_grounded:
		emit_signal("grounded_updated", is_grounded)
	
func _handle_movement(var move_speed = self.move_speed):
	var move_input_speed = -Input.get_action_strength("move_left") + Input.get_action_strength("move_right")
	velocity.x = lerp(velocity.x, move_speed * move_input_speed, _get_h_weight())
	if move_direction != 0:
		$Body.scale.x = move_direction
		
	if Input.is_action_pressed("move_left") or velocity.x < 0:
		Globals.playerfacing = -1 
	elif Input.is_action_pressed("move_right") or velocity.x > 0:
		Globals.playerfacing = 1

func _handle_wall_slide_sticking(): #timer to control the stick to walls
	if move_direction != 0 && move_direction != wall_direction:
		if wall_slide_sticky_timer.is_stopped():
			wall_slide_sticky_timer.start()
	else:
		wall_slide_sticky_timer.stop()

func _get_h_weight():
	if is_on_floor():
		return 0.2
	else:
		if move_direction == 0:
			return 0.02
		elif move_direction == sign(velocity.x) && abs(velocity.x) > move_speed: 
			return 0.0 
		else:
			return 0.1

func _check_is_grounded(raycasts = self.raycasts):
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true	
#Use of raycasts to detect if the player touches the ground
	return false

func jump():
	velocity.y = Globals.max_jump_velocity 
	is_jumping = true
	
func wall_jump():
	var wall_jump_velocity = WALL_JUMP_VELOCITY
	wall_jump_velocity.x *= -wall_direction
	velocity = wall_jump_velocity 

func variable_jump():
	if velocity.y < Globals.min_jump_velocity:
		velocity.y = Globals.min_jump_velocity

func _update_wall_direction():
	var is_near_wall_left = _check_is_valid_wall(left_wall_raycasts)
	var is_near_wall_right = _check_is_valid_wall(right_wall_raycasts)
#Determine the direction of the detected wall
	if is_near_wall_left && is_near_wall_right:
		wall_direction = move_direction
	else:
		wall_direction = -int(is_near_wall_left) + int(is_near_wall_right)
		
func _check_is_valid_wall(wall_raycasts):
	for raycast in wall_raycasts.get_children():
		if raycast.is_colliding():
			var dot = acos(Vector2.UP.dot(raycast.get_collision_normal()))
			if dot > PI * 0.35 && dot < PI * 0.55:
				return true
#Use to identify if there's walls
	return false

func spawn_godot():
#Function to spawn items to throw
	if held_item == null:
		held_item = GodotProjectile_PS.instance()
		held_item_position.add_child(held_item)
		
func _throw_held_item():
#Function to throw spawned items
	held_item.launch(Globals.playerfacing)
	held_item = null

func _on_Area2D_body_exited(body):
	set_collision_mask_bit(DROP_THRU_BIT, true)
#to let the player pass through == drop-through platform
func damage(damage_amount):
#Damage function controlled by invulnerability timer. Add the condition of dodging_timer --> dodge = no damage
	if invulnerability_timer.is_stopped() && dodging_timer.is_stopped():
		invulnerability_timer.start()
		_set_health(health - damage_amount)
		effects_animation.play("playerdamage")
		effects_animation.queue("playerflash")
	
func kill():
	print("KILLED")
	
func _set_health(value):
#Effective function for changing health
	var prev_health = health
	health = clamp(value, 0, max_health)
	if health != prev_health:
		emit_signal("health_updated", health)
		if health == 0:
			kill()
			#emit_signal("killed")

func _on_InvulnerabilityTimer_timeout():
	effects_animation.play("playerrest")
#to see visually when the invulnerability timer is off

func _on_crouch():
#Change collision when crouching
	standing_collision.disabled = true
	crouching_collision.disabled = false
	standing_hitbox.disabled = true
	crouching_hitbox.disabled = false

func _on_stand():
#Change collision when getting back to idle
	standing_hitbox.disabled = false
	crouching_hitbox.disabled = true
	
	while standing_collision.disabled && !state_machine.is_crouched():
		if can_stand():
			standing_collision.disabled = false
			crouching_collision.disabled = true
		yield(get_tree(), "physics_frame")
		
func can_stand() -> bool: 
#to check if the character can stand or not where he's
	var space_state = get_world_2d().direct_space_state
	var query = Physics2DShapeQueryParameters.new()
	query.set_shape(standing_collision.shape)
	query.transform = standing_collision.global_transform
	query.collision_layer = collision_mask
	var results = space_state.intersect_shape(query)
	for i in range(results.size() - 1, -1, -1):
		var collider = results[i].collider
		var shape = results[i].shape
		if collider is CollisionObject2D && collider.is_shape_owner_one_way_collision_enabled(shape):
			results.remove(i)
		elif collider is TileMap:
			var tile_id = collider.get_cellv(results[i].metadata)
			if collider.tile_set.tile_get_shape_one_way(tile_id, 0):
				results.remove(i)
	return results.size() == 0

