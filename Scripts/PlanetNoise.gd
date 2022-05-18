tool
extends Resource

class_name PlanetNoise

export var is_enabled := true setget set_is_enabled
export var amplitude : float = 1.0 setget set_amplitude
export var min_height : float = 0.0 setget set_min_height
#xport(int, 0, 8) var layers : int = 1 setget set_layers
export var use_first_layer_as_mask : bool = false setget set_first_layer_as_mask
export var strength : float = 1.0 setget set_strenght
export var centre : Vector3 setget set_centre

export var noise_map : OpenSimplexNoise setget set_noise_map

#func set_layers(val):
#	layers = val
#	emit_signal("changed")

func set_is_enabled(val):
	is_enabled = val
	emit_signal("changed")

func set_strenght(val):
	strength = val
	emit_signal("changed")
	
func set_centre(val):
	centre = val
	emit_signal("changed")

func set_first_layer_as_mask(val):
	use_first_layer_as_mask = val
	emit_signal("changed")

func set_min_height(val):
	min_height = val
	emit_signal("changed")
	
func set_amplitude(val):
	amplitude = val
	emit_signal("changed")
	
func set_noise_map(val):
	noise_map = val
	emit_signal("changed")
	if noise_map != null and not noise_map.is_connected("changed", self, "on_data_changed"):
		noise_map.connect("changed", self, "on_data_changed")
		
func on_data_changed():
	emit_signal("changed")
