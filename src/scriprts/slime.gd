extends Area2D

@onready var audio_hurt: AudioStreamPlayer = $Hurt

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("on_attack_by_slime"):
			body.on_attack_by_slime()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("arrow"):
		GameController.handle_add_score(1)
		hide()
		area.hide()
		audio_hurt.play()
		audio_hurt.finished.connect(audio_finish.bind(self ))

func audio_finish(area: Area2D):
	queue_free()
	area.queue_free()
