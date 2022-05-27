tool
extends Resource

class_name PlanetSettings

export var radius := 1.0 setget set_radius
export var resolution := 10 setget set_resolution
export(Array, Resource) var planet_noise setget set_planet_noise
#export var planet_color : GradientTexture setget set_planet_color
export (Array, Resource) var biomes setget set_biomes
export var biome_noise : OpenSimplexNoise setget set_biome_noise
export var biome_amplitude : float setget set_biome_amplitude
export var biome_offset : float setget set_biome_offset
export(float, 0.0, 1.0) var biome_blend setget set_biome_blend

var min_height := 99999.0
var max_height := 0.0

func set_biome_blend(val):
	biome_blend = val
	emit_signal("changed")

func set_biome_noise(val):
	biome_noise = val
	emit_signal("changed")
	if not biome_noise.is_connected("changed", self, "on_data_changed"):
		biome_noise.connect("changed", self, "on_data_changed")

func set_biome_amplitude(val):
	biome_amplitude = val
	emit_signal("changed")
	
func set_biome_offset(val):
	biome_offset = val
	emit_signal("changed")

func set_biomes(val):
	biomes = val
	for i in range (biomes.size()):
		if biomes[i] == null:
			biomes[i] = BiomeSettings.new()
		if not biomes[i].is_connected("changed", self, "on_data_changed"):
			biomes[i].connect("changed", self, "on_data_changed")
	emit_signal("changed")

#func set_planet_color(val):
#	planet_color = val
#	if planet_color != null and not planet_color.is_connected("changed", self, "on_data_changed"):
#			planet_color.connect("changed", self, "on_data_changed")

func set_radius(val):
	radius = val
	emit_signal("changed")
	
func set_resolution(val):
	resolution = val
	emit_signal("changed")
	
func set_planet_noise(val):
	planet_noise = val
	emit_signal("changed")
	for n in planet_noise:
		if n != null and not n.is_connected("changed", self, "on_data_changed"):
			n.connect("changed", self, "on_data_changed")
		
func on_data_changed():
	emit_signal("changed")
	
	
