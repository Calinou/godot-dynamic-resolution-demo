extends AnimationPlayer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_pause"):
		playback_speed = 1 if playback_speed == 0 else 0
		print(playback_speed)
