extends KinematicBody2D

const SLOPE_STOP_THRESHOLD = 64
signal health_updated(health)
############
signal grounded_updated(is_grounded)
signal killed()
############

<<<<<<< HEAD
onready var anim_sb = $Body/SleepingBallRig/AnimationPlayer
=======
signal health_updated(health)
signal killed()

onready var anim_player = $Body/SleepingBallRig/AnimationPlayer
>>>>>>> Slipi
onready var hitbox = $Hitbox
onready var effects_animation = $Body/SleepingBallRig/EffectsAnimation
onready var invulnerability_timer = $InvulnerabilityTimer

export (float) var max_health = 100
onready var health = max_health setget _set_health

var move_speed = 3 * Globals.UNIT_SIZE
var velocity = Vector2()
var move_direction

var is_grounded = false#to pe
var is_jumping = false

func _apply_gravity(delta):
	velocity.y += Globals.gravity * delta

func _apply_movement():

	
	if move_direction == 0 && abs(velocity.x) < SLOPE_STOP_THRESHOLD:
		velocity.x = 0
	var stop_on_slope = true if get_floor_velocity().x == 0 else false
	var snap = Vector2.ZERO
	velocity = move_and_slide_with_snap(velocity, snap, Globals.UP, stop_on_slope)
	
	var was_grounded = is_grounded
	is_grounded = is_on_floor()   #!is_jumping
	
	if was_grounded == null || is_grounded != was_grounded:
		emit_signal("grounded_updated", is_grounded)



func damage(damage_amount):
	
	if invulnerability_timer.is_stopped():
		invulnerability_timer.start()
		_set_health(health - damage_amount)
		effects_animation.play("sleepingballdamage")
		effects_animation.queue("sleepingballflash")
	
func kill():
	queue_free()
	
func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	if health != prev_health:
		emit_signal("health_updated", health)
		if health == 0:
			kill()
			emit_signal("killed")


func _on_InvulnerabilityTimer_timeout():
	effects_animation.play("sleepingballrest")
###############
func _should_turn():
	pass
func _should_chase():
	pass
func _should_sleep():
	pass
func turn():
	pass
func _chase_player():
	move_local_x(get_node("../Player").position, move_speed)
func _stop():
	pass
func _apply_velocity():
	pass
#	move_direction = -(Vector2(move_speed,0)) + (Vector2(-move_speed,0))
#	velocity.x = lerp(velocity.x, move_speed * move_direction, _get_h_weight())
#	if move_direction != 0:
#		$Body.scale.x = move_direction
func _should_attack():
	pass
func attack():
	pass
func _get_h_weight():
	return 0.2 if is_grounded else 0.1

