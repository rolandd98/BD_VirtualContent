extends Resource

class_name BiomeGenerator

static func update_biome_texture(PlanetSettings : PlanetSettings) -> ImageTexture:
	var biomes = PlanetSettings.biomes
	var image_texture = ImageTexture.new()
	var dyn_image = Image.new() #dynamic texture
	
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
	
static func biome_percent_from_point(point_on_unit_sphere : Vector3, PlanetSettings : PlanetSettings) -> float: #Y coordinate of our texture
	var biome_noise = PlanetSettings.biome_noise
	var biome_offset = PlanetSettings.biome_offset
	var biome_amplitude = PlanetSettings.biome_amplitude
	var biome_blend = PlanetSettings.biome_blend
	var biomes = PlanetSettings.biomes
	
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
	
