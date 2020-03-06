extends Label

onready var rect: TextureRect = $"../../DynamicResolutionViewport"

func _process(delta):
	text = str(rect.scale_factor).pad_decimals(2)
