extends KinematicBody2D

signal grounded_updated(is_grounded)

signal health_updated(health)
signal killed()

const GodotProjectile_PS = preload("res://src/entity/weapons/GodotProjectile.tscn")


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
var is_grounded = false#to permit a check_ground method associated with raycasts
var is_wall_sliding = false
var wall_direction = 1

onready var left_wall_raycasts = $WallRaycasts/LeftWallRaycasts
onready var right_wall_raycasts = $WallRaycasts/RightWallRaycasts
onready var wall_slide_cooldown = $WallSlideCooldown
onready var wall_slide_sticky_timer = $WallSlideStickyTimer
onready var body = $Body
onready var drop_thru_raycasts = $DropThruRaycasts
onready var raycasts = $Raycasts
onready var anim_player = $Body/PlayerRig/AnimationPlayer
onready var held_item_position = $Body/PlayerRig/Torso/RightArm/HeldItemPosition
onready var hitbox = $Hitbox
onready var invulnerability_timer = $InvulnerabilityTimer
onready var effects_animation = $Body/PlayerRig/EffectsAnimation


func _ready():
	Globals.player = self

func _apply_gravity(delta):
	velocity.y += Globals.gravity * delta
	if is_wall_sliding:
		_cap_gravity_wall_slide()

func _update_move_direction():
	move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right")) #inputs for movement
	
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
	
func _handle_move_input():
	velocity.x = lerp(velocity.x, move_speed * move_direction, _get_h_weight())
	if move_direction != 0:
		$Body.scale.x = move_direction
		
	if Input.is_action_pressed("move_left") or velocity.x < 0:
		Globals.playerfacing = -1 
	elif Input.is_action_pressed("move_right") or velocity.x > 0:
		Globals.playerfacing = 1

func _handle_wall_slide_sticking():
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
		elif move_direction == sign(velocity.x) && abs(velocity.x) > Globals.move_speed: 
			return 0.0 
		else:
			return 0.1

func _check_is_grounded(raycasts= self.raycasts):
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true	
	
	return false

func jump():
	Globals.velocity.y = Globals.max_jump_velocity 
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
	return false

func spawn_godot():
	if held_item == null:
		held_item = GodotProjectile_PS.instance()
		held_item_position.add_child(held_item)
		
func _throw_held_item():
	held_item.launch(Globals.playerfacing)
	held_item = null

func _on_Area2D_body_exited(body):
	set_collision_mask_bit(DROP_THRU_BIT, true)

func damage(damage_amount):
	if invulnerability_timer.is_stopped():
		invulnerability_timer.start()
		_set_health(health - damage_amount)
		effects_animation.play("playerdamage")
		effects_animation.queue("playerflash")
	
func kill():
	print("KILLED")
	
func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	if health != prev_health:
		emit_signal("health_updated", health)
		if health == 0:
			kill()
			#emit_signal("killed")

func _on_InvulnerabilityTimer_timeout():
	effects_animation.play("playerrest")

