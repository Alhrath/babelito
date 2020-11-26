extends KinematicBody2D

signal grounded_updated(is_grounded)

const UP = Vector2(0,-1)
const SLOPE_STOP = 64
const DROP_THRU_BIT = 1 # collision variable for dropping through platform

var velocity = Vector2()
var move_speed = 5 * Globals.UNIT_SIZE
var gravity #= 1200
var max_jump_velocity #var jump_velocity = -720
var min_jump_velocity 
var is_jumping = false #useful to create platform drop through

var max_jump_height = 3.25 * Globals.UNIT_SIZE
var min_jump_height = 0.05 * Globals.UNIT_SIZE
var jump_duration = 0.45

var is_grounded #to permit a check_ground method associated with raycasts
onready var raycasts = $Raycasts

onready var anim_player = $Body/PlayerRig/AnimationPlayer

func _ready():
	gravity = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)
	
func _physics_process(delta):
	_get_input()
	velocity.y += gravity * delta
	
	if is_jumping && velocity.y >= 0:
		is_jumping = false
	
	velocity = move_and_slide(velocity, UP, SLOPE_STOP)
	
	is_grounded = !is_jumping && get_collision_mask_bit(DROP_THRU_BIT) && _check_is_grounded()
	var was_grounded = is_grounded
	if was_grounded == null || is_grounded != was_grounded:
		emit_signal("grounded_updated", is_grounded)
		
	_assign_animation()

func _input(event): 
	if event.is_action_pressed("jump") && is_grounded:  #single jump 
			velocity.y = max_jump_velocity
			is_jumping = true
			
	if Input.is_action_pressed("down") && _check_is_grounded($DropThruRaycasts):
		set_collision_mask_bit(DROP_THRU_BIT, false)
	
	if event.is_action_released("jump") && velocity.y < min_jump_velocity:
		velocity.y = min_jump_velocity
		
func _get_input():
	var move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	velocity.x = lerp(velocity.x, move_speed * move_direction, _get_h_weight())
	if move_direction != 0:
		$Body.scale.x = move_direction
	
func _get_h_weight():
	return 0.2 if is_grounded else 0.1

# warning-ignore:shadowed_variable
func _check_is_grounded(raycasts = self.raycasts):
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true	
	
	return false

func _assign_animation():
	var anim = "idle"
	
	if !is_grounded:
		anim= "jump"
		
	elif velocity.x != 0:
		anim = "run"
	
	if anim_player.assigned_animation != anim:
		anim_player.play(anim)


# warning-ignore:unused_argument
func _on_Area2D_body_exited(body):
	set_collision_mask_bit(DROP_THRU_BIT, true)
