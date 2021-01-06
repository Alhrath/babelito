extends Node

signal player_initialised()

var player

func _process(delta):
	if not player:
		initialise_player()
		return

func initialise_player():
	player = get_tree().get_root().get_node("/root/Level0/Player")
	if not player:
		return
	
	emit_signal("player_initialised", player)
	
	player.inventory.connect("inventory_changed", self, "_on_player_inventory_changed")
	
	var existing_inventory = load("user://inventory.tres")
	
	if existing_inventory:
		player.inventory.set_items(existing_inventory.get_items())
	else:
		pass
		
func _on_player_inventory_changed(inventory):
	ResourceSaver.save("user://inventory.tres", inventory)

