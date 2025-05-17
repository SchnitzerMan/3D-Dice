extends Node3D

# Define camera variables
var camera: Camera3D
var camera_height: float = 4.0
var camera_distance: float = 5.0
var camera_rotation: float = 0.0

# Add input mapping
func _ready():
	# Set up input actions if they don't exist
	_setup_input_actions()
	
	# Create table with edges
	create_octagonal_table()
	
	# Set up environment
	setup_environment()
	
	# Add initial dice for testing
	create_dice(Vector3(0, 3, 0))

# Set up input actions for better input handling
func _setup_input_actions():
	if not InputMap.has_action("rotate_left"):
		InputMap.add_action("rotate_left")
		var event_a = InputEventKey.new()
		event_a.keycode = KEY_A
		InputMap.action_add_event("rotate_left", event_a)
	
	if not InputMap.has_action("rotate_right"):
		InputMap.add_action("rotate_right")
		var event_d = InputEventKey.new()
		event_d.keycode = KEY_D
		InputMap.action_add_event("rotate_right", event_d)
	
	if not InputMap.has_action("camera_up"):
		InputMap.add_action("camera_up")
		var event_w = InputEventKey.new()
		event_w.keycode = KEY_W
		InputMap.action_add_event("camera_up", event_w)
	
	if not InputMap.has_action("camera_down"):
		InputMap.add_action("camera_down")
		var event_s = InputEventKey.new()
		event_s.keycode = KEY_S
		InputMap.action_add_event("camera_down", event_s)
	
	if not InputMap.has_action("zoom_in"):
		InputMap.add_action("zoom_in")
		var event_e = InputEventKey.new()
		event_e.keycode = KEY_E
		InputMap.action_add_event("zoom_in", event_e)
	
	if not InputMap.has_action("zoom_out"):
		InputMap.add_action("zoom_out")
		var event_q = InputEventKey.new()
		event_q.keycode = KEY_Q
		InputMap.action_add_event("zoom_out", event_q)
	
	if not InputMap.has_action("spawn_dice"):
		InputMap.add_action("spawn_dice")
		var event_space = InputEventKey.new()
		event_space.keycode = KEY_SPACE
		InputMap.action_add_event("spawn_dice", event_space)

func create_octagonal_table():
	# Table dimensions
	var radius = 2.0
	var edge_height = 0.3
	var table_thickness = 0.1
	var num_sides = 8
	
	# Create table surface
	var table_surface = StaticBody3D.new()
	table_surface.name = "TableSurface"
	add_child(table_surface)
	
	# Create the table using a custom mesh instead of CSGPolygon3D
	# This ensures it's oriented correctly on the XZ plane
	var surface_mesh = MeshInstance3D.new()
	surface_mesh.name = "SurfaceMesh"
	table_surface.add_child(surface_mesh)
	
	# Create a custom octagonal mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Create the top face (normal pointing up)
	var top_y = 0.0
	st.set_normal(Vector3(0, 1, 0))
	
	# Create vertices for top face
	var top_vertices = []
	for i in range(num_sides):
		var angle = i * 2 * PI / num_sides
		top_vertices.append(Vector3(cos(angle) * radius, top_y, sin(angle) * radius))
	
	# Triangulate the top face (fan triangulation from center)
	for i in range(num_sides):
		var next_i = (i + 1) % num_sides
		st.add_vertex(Vector3(0, top_y, 0))  # Center vertex
		st.add_vertex(top_vertices[i])
		st.add_vertex(top_vertices[next_i])
	
	# Create the bottom face (normal pointing down)
	var bottom_y = -table_thickness
	st.set_normal(Vector3(0, -1, 0))
	
	# Create vertices for bottom face
	var bottom_vertices = []
	for i in range(num_sides):
		var angle = i * 2 * PI / num_sides
		bottom_vertices.append(Vector3(cos(angle) * radius, bottom_y, sin(angle) * radius))
	
	# Triangulate the bottom face (fan triangulation from center)
	for i in range(num_sides):
		var next_i = (i + 1) % num_sides
		st.add_vertex(Vector3(0, bottom_y, 0))  # Center vertex
		st.add_vertex(bottom_vertices[next_i])  # Reverse winding order for bottom face
		st.add_vertex(bottom_vertices[i])
	
	# Create the side faces
	for i in range(num_sides):
		var next_i = (i + 1) % num_sides
		
		# Calculate the face normal (pointing outward)
		var side_normal = (top_vertices[i] + top_vertices[next_i]).normalized()
		side_normal.y = 0  # Ensure normal is horizontal
		st.set_normal(side_normal)
		
		# Add two triangles for the side face
		st.add_vertex(top_vertices[i])
		st.add_vertex(bottom_vertices[i])
		st.add_vertex(top_vertices[next_i])
		
		st.add_vertex(bottom_vertices[i])
		st.add_vertex(bottom_vertices[next_i])
		st.add_vertex(top_vertices[next_i])
	
	# Create the mesh
	surface_mesh.mesh = st.commit()
	
	# Apply material
	surface_mesh.material_override = create_table_material(Color(0.2, 0.6, 0.3))  # Green table
	
	# Add collision shape for the table surface
	var collision = CollisionShape3D.new()
	collision.name = "SurfaceCollision"
	table_surface.add_child(collision)
	
	# Create a convex polygon shape for the collision
	var shape = ConvexPolygonShape3D.new()
	var points = PackedVector3Array()
	
	# Add top points
	for i in range(num_sides):
		var angle = i * 2 * PI / num_sides
		points.append(Vector3(cos(angle) * radius, top_y, sin(angle) * radius))
	
	# Add bottom points
	for i in range(num_sides):
		var angle = i * 2 * PI / num_sides
		points.append(Vector3(cos(angle) * radius, bottom_y, sin(angle) * radius))
	
	shape.points = points
	collision.shape = shape
	
	# Create edges
	create_table_edges(radius, edge_height, table_thickness, num_sides)

func create_table_edges(radius, edge_height, table_thickness, num_sides):
	var edges = Node3D.new()
	edges.name = "TableEdges"
	add_child(edges)
	
	# Create edges for each side of the octagon
	for i in range(num_sides):
		var start_angle = i * 2 * PI / num_sides
		var end_angle = ((i + 1) % num_sides) * 2 * PI / num_sides
		
		var start_pos = Vector3(cos(start_angle) * radius, 0, sin(start_angle) * radius)
		var end_pos = Vector3(cos(end_angle) * radius, 0, sin(end_angle) * radius)
		
		# Find the midpoint and direction for this edge
		var mid_pos = (start_pos + end_pos) / 2
		var direction = (end_pos - start_pos).normalized()
		var edge_length = start_pos.distance_to(end_pos)
		
		# Create edge body
		var edge = StaticBody3D.new()
		edge.name = "Edge_" + str(i)
		edge.transform.origin = mid_pos
		edges.add_child(edge)
		
		# Create visual mesh for the edge
		var edge_mesh = MeshInstance3D.new()
		edge_mesh.name = "EdgeMesh"
		edge.add_child(edge_mesh)
		
		# Create a custom box mesh for the edge
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		
		# Calculate edge dimensions
		var half_length = edge_length / 2
		var half_height = edge_height / 2
		var half_thickness = 0.05  # Half thickness of the edge
		
		# Calculate the edge normal (pointing outward)
		var edge_normal = Vector3(-direction.z, 0, direction.x).normalized()
		
		# Calculate the eight corners of the box
		var p1 = Vector3(-half_length, -half_height, -half_thickness)  # Bottom back left
		var p2 = Vector3(half_length, -half_height, -half_thickness)   # Bottom back right
		var p3 = Vector3(half_length, -half_height, half_thickness)    # Bottom front right
		var p4 = Vector3(-half_length, -half_height, half_thickness)   # Bottom front left
		var p5 = Vector3(-half_length, half_height, -half_thickness)   # Top back left
		var p6 = Vector3(half_length, half_height, -half_thickness)    # Top back right
		var p7 = Vector3(half_length, half_height, half_thickness)     # Top front right
		var p8 = Vector3(-half_length, half_height, half_thickness)    # Top front left
		
		# Front face
		st.set_normal(Vector3(0, 0, 1))
		st.add_vertex(p4)
		st.add_vertex(p3)
		st.add_vertex(p8)
		st.add_vertex(p8)
		st.add_vertex(p3)
		st.add_vertex(p7)
		
		# Back face
		st.set_normal(Vector3(0, 0, -1))
		st.add_vertex(p2)
		st.add_vertex(p1)
		st.add_vertex(p6)
		st.add_vertex(p6)
		st.add_vertex(p1)
		st.add_vertex(p5)
		
		# Left face
		st.set_normal(Vector3(-1, 0, 0))
		st.add_vertex(p1)
		st.add_vertex(p4)
		st.add_vertex(p5)
		st.add_vertex(p5)
		st.add_vertex(p4)
		st.add_vertex(p8)
		
		# Right face
		st.set_normal(Vector3(1, 0, 0))
		st.add_vertex(p3)
		st.add_vertex(p2)
		st.add_vertex(p7)
		st.add_vertex(p7)
		st.add_vertex(p2)
		st.add_vertex(p6)
		
		# Top face
		st.set_normal(Vector3(0, 1, 0))
		st.add_vertex(p8)
		st.add_vertex(p7)
		st.add_vertex(p5)
		st.add_vertex(p5)
		st.add_vertex(p7)
		st.add_vertex(p6)
		
		# Bottom face
		st.set_normal(Vector3(0, -1, 0))
		st.add_vertex(p1)
		st.add_vertex(p2)
		st.add_vertex(p4)
		st.add_vertex(p4)
		st.add_vertex(p2)
		st.add_vertex(p3)
		
		edge_mesh.mesh = st.commit()
		
		# Create a basis to orient the edge correctly
		# We want the edge to face outward from the table
		var x_axis = direction
		var y_axis = Vector3(0, 1, 0)
		var z_axis = edge_normal
		var basis = Basis(x_axis, y_axis, z_axis)
		edge.transform.basis = basis
		
		# Position the edge at table level
		edge.transform.origin.y = edge_height / 2
		
		# Apply material
		edge_mesh.material_override = create_table_material(Color(0.4, 0.2, 0.1))  # Brown edges
		
		# Add collision shape for the edge
		var collision = CollisionShape3D.new()
		collision.name = "EdgeCollision"
		edge.add_child(collision)
		
		# Use a box shape for collision
		var shape = BoxShape3D.new()
		shape.size = Vector3(edge_length, edge_height, 0.1)
		collision.shape = shape

func create_table_material(color):
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	return material

func setup_environment():
	# Add a camera
	camera = Camera3D.new()
	camera.name = "Camera"
	camera.transform.origin = Vector3(0, camera_height, camera_distance)  # Initial position
	camera.transform = camera.transform.looking_at(Vector3(0, 0, 0))
	camera.current = true  # Make it the active camera
	add_child(camera)
	
	# Add a light
	var light = DirectionalLight3D.new()
	light.name = "DirectionalLight"
	light.transform.basis = Basis(Quaternion(Vector3(1, 0, 0), -0.7))
	light.light_energy = 1.5  # Make it brighter
	add_child(light)
	
	# Add environment
	var world_environment = WorldEnvironment.new()
	world_environment.name = "WorldEnvironment"
	add_child(world_environment)
	
	var environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.1, 0.1, 0.2)  # Dark blue background
	environment.ambient_light_color = Color(0.3, 0.3, 0.3)  # Soft ambient light
	environment.ssao_enabled = true  # Add ambient occlusion for better depth
	world_environment.environment = environment
	
	# Add a HUD label with controls
	var control = Control.new()
	control.name = "HUD"
	add_child(control)
	
	var label = Label.new()
	label.text = "Controls:\nSpace - Spawn dice\nA/D - Rotate camera\nW/S - Adjust camera height\nQ/E - Zoom camera"
	label.position = Vector2(20, 20)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	control.add_child(label)

# Add this function to create dice with better visuals
func create_dice(position=Vector3(0, 3, 0), size=0.5):
	var dice = RigidBody3D.new()
	dice.name = "Dice"
	dice.transform.origin = position
	# Add random rotation for more interesting rolls
	dice.rotation = Vector3(randf() * PI, randf() * PI, randf() * PI)
	add_child(dice)
	
	# Create dice mesh
	var dice_mesh = MeshInstance3D.new()
	dice_mesh.name = "DiceMesh"
	dice.add_child(dice_mesh)
	
	# Create a box mesh for the die
	var boxMesh = BoxMesh.new()
	boxMesh.size = Vector3(size, size, size)
	dice_mesh.mesh = boxMesh
	
	# Create dice material with numbers
	var dice_material = create_dice_material()
	dice_mesh.material_override = dice_material
	
	# Add collision shape
	var collision = CollisionShape3D.new()
	collision.name = "DiceCollision"
	dice.add_child(collision)
	
	var shape = BoxShape3D.new()
	shape.size = Vector3(size, size, size)
	collision.shape = shape
	
	# Set physics properties
	dice.mass = 1.0
	dice.physics_material_override = PhysicsMaterial.new()
	dice.physics_material_override.bounce = 0.3
	dice.physics_material_override.friction = 0.8
	
	# Add some random force to make it roll
	dice.apply_central_impulse(Vector3(randf_range(-2, 2), 0, randf_range(-2, 2)))
	
	return dice

# Create a nice material for the dice
func create_dice_material():
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.9, 0.9, 0.9)  # Off-white color
	material.roughness = 0.2  # Slightly polished
	material.metallic = 0.1
	
	# You can add more advanced materials like textures for dice numbers
	# but that would require creating and loading external textures
	
	return material

# Add camera movement
func _process(delta):
	# Handle camera movement using actions
	if Input.is_action_pressed("rotate_left"):
		camera_rotation -= delta * 1.0
	if Input.is_action_pressed("rotate_right"):
		camera_rotation += delta * 1.0
	if Input.is_action_pressed("camera_up"):
		camera_height += delta * 2.0
	if Input.is_action_pressed("camera_down"):
		camera_height = max(1.0, camera_height - delta * 2.0)
	if Input.is_action_pressed("zoom_out"):
		camera_distance += delta * 2.0
	if Input.is_action_pressed("zoom_in"):
		camera_distance = max(2.0, camera_distance - delta * 2.0)
	
	# Update camera position
	var cam_x = sin(camera_rotation) * camera_distance
	var cam_z = cos(camera_rotation) * camera_distance
	camera.transform.origin = Vector3(cam_x, camera_height, cam_z)
	camera.transform = camera.transform.looking_at(Vector3(0, 0, 0))

# Call this to add a die to test
func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		# Spawn dice at a random position above the table
		var random_x = (randf() - 0.5) * 1.0
		var random_z = (randf() - 0.5) * 1.0
		var dice_pos = Vector3(random_x, 3, random_z)
		create_dice(dice_pos)
	# Alternative way to check for spawn_dice action
	elif event.is_action_pressed("spawn_dice"):
		# Spawn dice at a random position above the table
		var random_x = (randf() - 0.5) * 1.0
		var random_z = (randf() - 0.5) * 1.0
		var dice_pos = Vector3(random_x, 3, random_z)
		create_dice(dice_pos)
