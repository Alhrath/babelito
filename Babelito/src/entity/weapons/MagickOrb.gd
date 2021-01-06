extends Area2D



func _on_MagickOrb_body_entered(body):
	if body == GameManager.player:
		GameManager.player.inventory.add_item("Magick Orb", 1)
		queue_free()
