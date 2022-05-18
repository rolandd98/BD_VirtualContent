tool
extends MeshInstance

class_name TerrainFace

#LocalUp
export var local_up : Vector3

func regenerate_mesh(PlanetSettings : PlanetSettings, objectType : int):
	
	#Main terrain face variables
	#MESH
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX) #Mesh array
	
	#RESOLUTION
	var resolution := PlanetSettings.resolution
	
	#AXISA AXISB
	var axisA := Vector3(local_up.y, local_up.z, local_up.x)
	var axisB : Vector3 = local_up.cross(axisA)
	
	#Generating mesh
	#MESH ArrayType arrays
	var vertex_array := PoolVector3Array()	#Verticies array
	var index_array := PoolIntArray() #Indicies array
	var normal_array := PoolVector3Array()
	var uv_array := PoolVector2Array()
	
	#Calculating required arrays size
	var num_vertices : int = resolution * resolution #verticies quantity
	var num_indices : int = (resolution-1) * (resolution-1) * 6 #indices quantity
	
	#Resizing arrays
	vertex_array.resize(num_vertices) #Verticies array
	index_array.resize(num_indices) #Indicies array
	normal_array.resize(num_vertices)
	uv_array.resize(num_vertices)
	
	
	var tri_index : int = 0
	
	
	for y in range(resolution):
		for x in range(resolution):
			#calculating index (number of interation in a loop)
			var i : int = x + y * resolution #SIMPLE COUNTER
			#Shows how far from the end is seach cycle (0-1) percent 
			var percent := Vector2(x,y) / (resolution-1)
			
			#Calculates point on terrain face
			var pointOnUnitCube : Vector3 = local_up + (percent.x-0.5) * 2.0 * axisA + (percent.y-0.5) * 2.0 * axisB
			var pointOnUnitSphere := pointOnUnitCube.normalized()
			#calculating biome index based on pointOnUnitSphere
			var biome_index = PlanetSettings.biome_percent_from_point(pointOnUnitSphere)

			#calculating point on planet
			var pointOnPlanet := ShapeGenerator.calculate_point_on_planet(PlanetSettings, pointOnUnitSphere)
		
			
			
			
			#var pointOnUnitSphere := pointOnUnitCube.normalized() * planet_data.radius
			
			#var pointOnPlanet := PlanetSettings.point_on_planet(pointOnUnitSphere, y)
			
			
			
			
			var pointOnObject
			
			if objectType == 0: #CUBE
				pointOnObject = pointOnUnitCube * PlanetSettings.radius
			elif objectType == 1: #SPHERE
				pointOnObject = pointOnUnitSphere * PlanetSettings.radius
			elif objectType == 2: #BLOB
				pointOnObject = ShapeGenerator.calculate_point_on_blob(PlanetSettings, pointOnUnitSphere)
			else: #PLANET
				pointOnObject = pointOnPlanet
			
			
			#vertex_array[i] = pointOnUnitCube
			#vertex_array[i] = pointOnUnitSphere
			vertex_array[i] = pointOnObject
			
			#TOLEARN
			uv_array[i] = Vector2(0.0, biome_index)
			#TOLEARN
			var l = pointOnPlanet.length()
			if l < PlanetSettings.min_height:
				PlanetSettings.min_height = l
			if l > PlanetSettings.max_height:
				PlanetSettings.max_height = l
			
			#Creating triangles for all verticies, except those which are along
			#right and bottom sides
			if x != resolution-1 and y != resolution-1:
				#First triangle
				index_array[tri_index+2] = i
				index_array[tri_index+1] = i+resolution+1
				index_array[tri_index] = i+resolution
				
				#Second triangle
				index_array[tri_index+5] = i
				index_array[tri_index+4] = i+1
				index_array[tri_index+3] = i+resolution+1
				tri_index += 6
	
	#RECALCULATING THE NORMALS
	for a in range(0, index_array.size(), 3):
		var b : int = a + 1
		var c : int = a + 2
		var ab : Vector3 = vertex_array[index_array[b]] - vertex_array[index_array[a]]
		var bc : Vector3 = vertex_array[index_array[c]] - vertex_array[index_array[b]]
		var ca : Vector3 = vertex_array[index_array[a]] - vertex_array[index_array[c]]
		var cross_ab_bc : Vector3 = ab.cross(bc) * -1.0
		var cross_bc_ca : Vector3 = bc.cross(ca) * -1.0
		var cross_ca_ab : Vector3 = ca.cross(ab) * -1.0
		normal_array[index_array[a]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
		normal_array[index_array[b]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
		normal_array[index_array[c]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
	
	for i in range(normal_array.size()):
		normal_array[i] = normal_array[i].normalized()
		
	#assigning verticies and triangles to the mesh
	arrays[Mesh.ARRAY_VERTEX] = vertex_array
	arrays[Mesh.ARRAY_INDEX] = index_array
	arrays[Mesh.ARRAY_NORMAL] = normal_array
	arrays[Mesh.ARRAY_TEX_UV] = uv_array
	
	#Calling function to update mesh
	call_deferred("_update_mesh", arrays, PlanetSettings)

	
func _update_mesh(arrays : Array, PlanetSettings : PlanetSettings):
	var _mesh := ArrayMesh.new()
	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	self.mesh = _mesh

	material_override.set_shader_param("min_height", PlanetSettings.min_height)
	material_override.set_shader_param("max_height", PlanetSettings.max_height)
	material_override.set_shader_param("height_color", PlanetSettings.update_biome_texture())

	
