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
			biomes[i] = BiomesSettings.new()
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
	
func update_biome_texture() -> ImageTexture:
	var image_texture = ImageTexture.new()
	var dyn_image = Image.new() #ddynamic texture
	
	var h : int = biomes.size()
	if h > 0:
		var data : PoolByteArray
		var w : int = biomes[0].gradient.width
		for b in biomes:
			data.append_array(b.gradient.get_data().get_data())
			
		dyn_image.create_from_data(w, h, false, Image.FORMAT_RGBA8, data)
		
		image_texture.create_from_image(dyn_image, 4) #creating texture from the image created ^
		# 4 is a flag that means Use filtering & dont use MIPMAPS
		image_texture.resource_name = "Biome Texture"
	
	return image_texture
	
func biome_percent_from_point(point_on_unit_sphere : Vector3) -> float: #Y coordinate of our texture
	var height_percent : float = (point_on_unit_sphere.y + 1.0) / 2.0
	height_percent += ((biome_noise.get_noise_3dv(point_on_unit_sphere*100.0)+1.0/2.0)-biome_offset) * biome_amplitude
	var biome_index : float = 0.0
	var num_biome : float = biomes.size()
	var blend_range : float = biome_blend / 2.0 + 0.0001
	for i in range(num_biome):
		#interpolating shaders between values
		var dst : float = height_percent - biomes[i].start_height
		var lerp_val = clamp(inverse_lerp(-blend_range, blend_range, dst), 0.0, 1.0)
		var weight : float = lerp_val
		biome_index *= (1-weight)
		biome_index += i * weight
#		if biomes[i].start_height < height_percent:
#			biome_index = i
#		else:
#			break
	return biome_index / max(1.0, num_biome - 1)
	
