extends Label

func _process(delta: float) -> void:
	text = "%s ms" % str(delta * 1000).pad_decimals(2)
