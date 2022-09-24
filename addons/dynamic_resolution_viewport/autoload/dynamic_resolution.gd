# Copyright © 2020-2022 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.
extends Node

## The Viewport node that displays the 3D world.
## This is set automatically from the `texture` property.
var viewport: Viewport

## If `true`, enables dynamic resolution. The root viewport's 3D scale property will be overridden
## every frame, so changes made to it in the project settings or via scripts won't apply.
var use_dynamic_resolution := true

## If the MSPF is lower than this value (i.e. the FPS is higher than the threshold),
## increase the rendering scale. This value is in milliseconds.
## Recommended value for 60 FPS target: 13.5
var raise_threshold := 13.5

## The scale increment to apply when the MSPF is lower than `raise_threshold`.
## Higher values will scale up more aggressively, resulting in better visual quality
## at the cost of performance.
var raise_fraction = 0.01

## If the MSPF is higher than this value (i.e. the FPS is lower than the threshold),
## decrease the rendering scale. This value is in milliseconds.
## Recommended value for 60 FPS target: 14.0
var drop_threshold := 14.0

## The scale decrement to apply when the MSPF is higher than `drop_threshold`.
## Higher values will scale down more aggressively, resulting in smoother performance
## at the cost of visual quality.
var drop_fraction = 0.1

## The minimum viewport scale factor. This should generally be set between 0.5 and 1.0.
var minimum_scale := 0.5

## The maximum viewport scale factor. Values above 1 can be used to allow
## supersampling if performance allows.
var maximum_scale := 1.0


func _process(delta: float) -> void:
	if not use_dynamic_resolution:
		return

	# Calculate resolution every 10 frames to spread out the cost of changing the viewport size.
	if Engine.get_process_frames() % 10 == 0:
		# Delta is in seconds, convert it to `milliseconds` for the comparison.
		if (delta * 1000) < raise_threshold:
			get_viewport().scaling_3d_scale = clamp(get_viewport().scaling_3d_scale + raise_fraction, minimum_scale, maximum_scale)
		elif (delta * 1000) > drop_threshold:
			get_viewport().scaling_3d_scale = clamp(get_viewport().scaling_3d_scale - drop_fraction, minimum_scale, maximum_scale)

