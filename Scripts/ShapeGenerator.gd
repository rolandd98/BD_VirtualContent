extends Resource

class_name ShapeGenerator

static func calculate_point_on_planet(PlanetSettings : PlanetSettings, point_on_sphere : Vector3) -> Vector3:
	#Point elevation
	var elevation : float = 0.0
	
	var base_elevation := 0.0

	if PlanetSettings.planet_noise.size() > 0:
		base_elevation = (PlanetSettings.planet_noise[0].noise_map.get_noise_3dv((point_on_sphere*100.0) 
		+ (PlanetSettings.planet_noise[0].centre *10))+1)*0.5
		base_elevation = (base_elevation + 1.0) / 2.0 * PlanetSettings.planet_noise[0].amplitude
		base_elevation = max(0.0, base_elevation - PlanetSettings.planet_noise[0].min_height)

	for n in PlanetSettings.planet_noise:
		var mask := 1.0
		if n.use_first_layer_as_mask:
			mask = base_elevation

		if n.is_enabled:
			var level_elevation : float = 0.0
#			for i in range(n.layers):
#				level_elevation += ((n.noise_map.get_noise_3dv((point_on_sphere*100) * n.roughness + (n.centre * 10))+1) * 0.5) * 1/(i+1)
			if n == PlanetSettings.planet_noise[0]:
				level_elevation = (n.noise_map.get_noise_3dv((point_on_sphere * 100.0) + (n.centre * 10))+1)*0.5 #get_noise_3dv return value between 0 and 1
			else:
				level_elevation = n.noise_map.get_noise_3dv((point_on_sphere * 100.0) + (n.centre * 10)) #get_noise_3dv return value between -1 and 1
				
				
			level_elevation = (level_elevation + 1.0) / 2.0 * (n.amplitude)
			level_elevation = max(0.0, level_elevation - n.min_height) * mask
			elevation += level_elevation
			elevation *= n.strength
		
		
		#Setting radius and elevation to point on sphere
	return point_on_sphere * PlanetSettings.radius * (elevation + 1.0)
	
static func calculate_point_on_blob(PlanetSettings : PlanetSettings, point_on_sphere : Vector3) -> Vector3:
	#Point elevation
	var elevation : float = 0.0
	

	for n in PlanetSettings.planet_noise:
		if n.is_enabled:
			var level_elevation = (n.noise_map.get_noise_3dv((point_on_sphere*100) * n.roughness + (n.centre * 10))+1) * 0.5 #get_noise_3dv return value between -1 and 1
			elevation += level_elevation
			elevation *= n.strength
		
		#Setting radius and elevation to point on sphere
	return point_on_sphere  * PlanetSettings.radius * (elevation + 1.0)	
