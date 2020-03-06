# Copyright © 2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.
extends TextureRect

## The Viewport node that displays the 3D world.
## This is set automatically from the `texture` property.
var viewport: Viewport

## If `false`, the scaling factor in `scale_factor` will be used as a constant value.
export var use_dynamic_resolution := true

## If the MSPF is lower than this value (i.e. the FPS is higher than the threshold),
## increase the rendering scale. This value is in milliseconds.
export(float, 1, 50) var raise_threshold := 13.5

## The scale increment to apply when the MSPF is lower than `raise_threshold`.
## Higher values will scale up more aggressively, resulting in better visual quality
## at the cost of performance.
export(float, 0.001, 1.0) var raise_fraction = 0.01

## If the MSPF is higher than this value (i.e. the FPS is lower than the threshold),
## decrease the rendering scale. This value is in milliseconds.
export(float, 1, 50) var drop_threshold := 14

## The scale decrement to apply when the MSPF is higher than `drop_threshold`.
## Higher values will scale down more aggressively, resulting in smoother performance
## at the cost of visual quality.
export(float, 0.001, 1.0) var drop_fraction = 0.1

## The minimum viewport scale factor. This should generally be set between 0.5 and 1.0.
export(float, 0.25, 2.0) var minimum_scale := 0.5

## The maximum viewport scale factor. Values above 1 can be used to allow
## supersampling if performance allows.
export(float, 0.25, 2.0) var maximum_scale := 1.0

## The viewport's current resolution scale. 1.0 is full (1:1) resolution.
export(float, 0.25, 2.0) var scale_factor := 1.0 setget set_scale_factor


func _ready() -> void:
	assert(texture != null, "Please set the DynamicResolutionViewport's Texture property to a ViewportTexture.")
	assert(texture is ViewportTexture, "Invalid texture type in DynamicResolutionViewport (must be a ViewportTexture).")

	viewport = get_parent().get_node(texture.viewport_path)

	# Forcibly enable filtering as dynamic resolution scaling requires filtering
	# to look good.
	texture.flags |= Texture.FLAG_FILTER
	
	# Configure the viewport settings MSAA automatically based on the Project Settings.
	viewport.shadow_atlas_size = ProjectSettings.get_setting("rendering/quality/shadow_atlas/size")
	viewport.msaa = ProjectSettings.get_setting("rendering/quality/filters/msaa")
	viewport.usage = ProjectSettings.get_setting("rendering/quality/intended_usage/framebuffer_allocation")

	get_tree().connect("screen_resized", self, "_on_screen_resized")
	_on_screen_resized()


func _process(delta: float) -> void:
	if not use_dynamic_resolution:
		return
		
	# Calculate resolution every 10 frames to spread out the cost of changing the viewport size.
	if Engine.get_idle_frames() % 10 == 0:
		# Delta is in seconds, convert it to `milliseconds` for the comparison.
		if (delta * 1000) < raise_threshold:
			self.scale_factor = clamp(scale_factor + raise_fraction, minimum_scale, maximum_scale)
		elif (delta * 1000) > drop_threshold:
			self.scale_factor = clamp(scale_factor - drop_fraction, minimum_scale, maximum_scale)


func _on_screen_resized() -> void:
	if viewport:
		viewport.size = OS.window_size * scale_factor


func set_scale_factor(p_scale_factor: float) -> void:
	if p_scale_factor != scale_factor:
		scale_factor = p_scale_factor
		_on_screen_resized()
