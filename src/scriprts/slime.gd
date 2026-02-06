extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("on_attack_by_slime"):
			body.on_attack_by_slime()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("arrow"):
		queue_free()
		area.queue_free()
