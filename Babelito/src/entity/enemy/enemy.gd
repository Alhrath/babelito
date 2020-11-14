extends "../entity.gd"

var ai_timer = null
var ai_wait_time = globals.AI_WAIT_TIME

func _ready():
	ai_timer = Timer.new()
	add_child(ai_timer)
	ai_timer.connect("timeout", self, "ai_loop")
	ai_timer.set_wait_time(ai_wait_time) # Maybe should 
	ai_timer.set_one_shot(false)
	ai_timer.start()

func ai_loop(): # Here to prevent bad function call. Should be replaced in specific enemy script, otherwise do nothing
	return false
