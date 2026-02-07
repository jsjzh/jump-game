extends Area2D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var collected: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if not collected:
			collected = true
			self.hide()
			GameController.handle_add_coin(1)
			audio_stream_player.play()
			audio_stream_player.finished.connect(queue_free)