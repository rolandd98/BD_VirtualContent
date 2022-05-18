tool
extends Spatial

class_name Planet

export var isRotating := true setget reset_rotation
export var rotationSpeed := 1.0
export(int, "Cube", "Sphere", "Blob", "Planet") var objectType := 3
export(int, "Earth-like", "Random") var planet_type := 1
export var generate = false setget generate_planet


export(Resource) var PlanetSettings setget set_planet_data
var rng = RandomNumberGenerator.new()

#Random Planet generation variables
func generate_planet(val = null):
	rng.randomize()
	
	if planet_type == 0: #Earth-like
		for child in PlanetSettings.planet_noise:
			child.strength = rng.randf_range(0.7, 1.5)
			child.noise_map.seed = rng.randf_range(0, 1000000.0)
			child.noise_map.period = rng.randf_range(30.0, 100.0)
			child.noise_map.persistence = 0.5
			child.noise_map.lacunarity = 2
	elif planet_type == 1: #Random
		for child in PlanetSettings.planet_noise:
			child.strength = rng.randf_range(0, 5.0)
			child.noise_map.seed = rng.randf_range(0, 1000000.0)
			child.noise_map.period = rng.randf_range(0, 100.0)
			child.noise_map.persistence = rng.randf_range(0, 1.0)
			child.noise_map.lacunarity = rng.randf_range(0, 4.0)


func reset_rotation(val):
	isRotating = val
	self.rotation_degrees = Vector3(0,0,0)
		
func set_planet_data(val):
	PlanetSettings = val
	on_data_changed()
	if PlanetSettings != null and not PlanetSettings.is_connected("changed", self, "on_data_changed"):
		PlanetSettings.connect("changed", self, "on_data_changed")
	
func _ready() -> void:
	on_data_changed()
	
	#Spinning the planet
func _physics_process(delta: float) -> void:
	if isRotating:
		self.rotate_y(rotationSpeed * delta)
		
func on_data_changed():
	PlanetSettings.min_height = 99999.0
	PlanetSettings.max_height = 0.0
	generate_mesh()
		
func generate_mesh():
	#Looping over all terrainfaces of the planet
	for child in get_children():
		var face := child as TerrainFace
		face.regenerate_mesh(PlanetSettings, objectType)
