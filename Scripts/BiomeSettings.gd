tool
extends Resource
class_name BiomeSettings

export var gradient : GradientTexture setget set_gradient
export var start_height : float setget set_start_height

func set_gradient(val):
	gradient = val
	emit_signal("changed")
	if not gradient.is_connected("changed", self, "on_data_changed"):
		gradient.connect("changed", self, "on_data_changed")

func set_start_height(val):
	start_height = val
	emit_signal("changed")
		
func on_data_changed():
	emit_signal("changed")
