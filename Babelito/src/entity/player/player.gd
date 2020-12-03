extends KinematicBody2D

signal grounded_updated(is_grounded)

signal health_updated(health)
signal killed()

const GodotProjectile_PS = preload("res://src/entity/weapons/GodotProjectile.tscn")


const SLOPE_STOP_THRESHOLD = 64
const DROP_THRU_BIT = 1 # collision variable for dropping through platform


export (float) var max_health = 100
onready var health = max_health setget _set_health

var velocity = Vector2()
var move_speed = 5 * Globals.UNIT_SIZE
var gravity #= 1200
var max_jump_velocity #var jump_velocity = -720
var min_jump_velocity 
var move_direction
var max_jump_height = 3.25 * Globals.UNIT_SIZE
var min_jump_height = 0.05 * Globals.UNIT_SIZE
var jump_duration = 0.45

var held_item = null

var is_jumping = false #useful to create platform drop through
var is_grounded = false#to permit a check_ground method associated with raycasts

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

func _apply_movement():

	if is_jumping && velocity.y >= 0:
		is_jumping = false
	
	var snap = Vector2.DOWN * 32 if !is_jumping else Vector2.ZERO
	
	if move_direction == 0 && abs(velocity.x) < SLOPE_STOP_THRESHOLD:
		velocity.x = 0
	var stop_on_slope = true if get_floor_velocity().x == 0 else false
	
	velocity = move_and_slide_with_snap(velocity, snap, Globals.UP, stop_on_slope)
	
	var was_grounded = is_grounded
	is_grounded = is_on_floor()  && get_collision_mask_bit(DROP_THRU_BIT) && _check_is_grounded() #!is_jumping
	
	if was_grounded == null || is_grounded != was_grounded:
		emit_signal("grounded_updated", is_grounded)
	
func _handle_move_input():
	move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	velocity.x = lerp(velocity.x, move_speed * move_direction, _get_h_weight())
	if move_direction != 0:
		$Body.scale.x = move_direction
	################################
	if Input.is_action_pressed("move_left") or velocity.x < 0:
		Globals.playerfacing = -1
#Globals.facing = -1
	elif Input.is_action_pressed("move_right") or velocity.x > 0:
		Globals.playerfacing = 1
#Globals.facing = 1
################################
	
func _get_h_weight():
	return 0.2 if is_grounded else 0.1


func _check_is_grounded(raycasts= self.raycasts):
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true	
	
	return false

func spawn_godot():
	if held_item == null:
		held_item = GodotProjectile_PS.instance()
		held_item_position.add_child(held_item)
		

func _throw_held_item():
	held_item.launch(Globals.playerfacing)
	#held_item.launch(Globals.facing)
	held_item = null

func _on_Area2D_body_exited(body):
	set_collision_mask_bit(DROP_THRU_BIT, true)




func damage(damage_amount):
	if invulnerability_timer.is_stopped():
		invulnerability_timer.start()
		_set_health(health - damage_amount)
		effects_animation.play("damage")
		effects_animation.queue("flash")
	
func kill():
	print("KILLED")
	
func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	if health != prev_health:
		emit_signal("health_updated", health)
		if health == 0:
			kill()
			emit_signal("killed")

func _on_InvulnerabilityTimer_timeout():
	effects_animation.play("rest")


