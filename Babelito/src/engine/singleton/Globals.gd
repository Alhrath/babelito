extends Node

const UNIT_SIZE = 64
const UP = Vector2(0, -1)
var player
##############
export var playerfacing = 1
#############3
export var facing = 0
#from player:

var velocity = Vector2()
var move_speed = 5 * UNIT_SIZE
var gravity 
var max_jump_velocity 
var min_jump_velocity 
var move_direction
var max_jump_height = 3.25 * UNIT_SIZE
var min_jump_height = 0.05 * UNIT_SIZE
var jump_duration = 0.45


func _ready():
	
	gravity = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)
	

