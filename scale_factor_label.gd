extends Label


func _process(delta):
	text = "%.2f" % get_viewport().scaling_3d_scale
