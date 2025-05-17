extends Node3D

# Constants for dice types and physics
const DICE_TYPES = {
	"d4": {"mesh": "res://dice/d4.tscn", "faces": 4},
	"d6": {"mesh": "res://dice/d6.tscn", "faces": 6},
	"d8": {"mesh": "res://dice/d8.tscn", "faces": 8},
	"d10": {"mesh": "res://dice/d10.tscn", "faces": 10},
	"d12": {"mesh": "res://dice/d12.tscn", "faces": 12},
	"d20": {"mesh": "res://dice/d20.tscn", "faces": 20}
}# Add helper functions for die creation
func create_tetrahedron_mesh() -> Mesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Define vertices
	var v0 = Vector3(0, 1, 0)
	var v1 = Vector3(-0.866, -0.5, -0.5)
	var v2 = Vector3(0.866, -0.5, -0.5)
	var v3 = Vector3(0, -0.5, 1)
	
	# Face 1
	st.add_vertex(v0)
	st.add_vertex(v1)
	st.add_vertex(v2)
	
	# Face 2
	st.add_vertex(v0)
	st.add_vertex(v2)
	st.add_vertex(v3)
	
	# Face 3
	st.add_vertex(v0)
	st.add_vertex(v3)
	st.add_vertex(v1)
	
	# Face 4
	st.add_vertex(v1)
	st.add_vertex(v3)
	st.add_vertex(v2)
	
	st.generate_normals()
	return st.commit()

func create_d10_points() -> PackedVector3Array:
	var points = PackedVector3Array()
	var phi = (1 + sqrt(5)) / 2  # Golden ratio
	
	# Simplified d10 points (should be more complex for accurate d10)
	points.append(Vector3(1, phi, 0).normalized() * 0.7)
	points.append(Vector3(-1, phi, 0).normalized() * 0.7)
	points.append(Vector3(1, -phi, 0).normalized() * 0.7)
	points.append(Vector3(-1, -phi, 0).normalized() * 0.7)
	points.append(Vector3(0, 1, phi).normalized() * 0.7)
	points.append(Vector3(0, -1, phi).normalized() * 0.7)
	points.append(Vector3(0, 1, -phi).normalized() * 0.7)
	points.append(Vector3(0, -1, -phi).normalized() * 0.7)
	points.append(Vector3(phi, 0, 1).normalized() * 0.7)
	points.append(Vector3(-phi, 0, 1).normalized() * 0.7)
	
	return points

func create_d12_points() -> PackedVector3Array:
	var points = PackedVector3Array()
	var phi = (1 + sqrt(5)) / 2  # Golden ratio
	
	# Add vertices of a dodecahedron
	points.append(Vector3(1, 1, 1).normalized() * 0.8)
	points.append(Vector3(1, 1, -1).normalized() * 0.8)
	points.append(Vector3(1, -1, 1).normalized() * 0.8)
	points.append(Vector3(1, -1, -1).normalized() * 0.8)
	points.append(Vector3(-1, 1, 1).normalized() * 0.8)
	points.append(Vector3(-1, 1, -1).normalized() * 0.8)
	points.append(Vector3(-1, -1, 1).normalized() * 0.8)
	points.append(Vector3(-1, -1, -1).normalized() * 0.8)
	
	points.append(Vector3(0, phi, 1/phi).normalized() * 0.8)
	points.append(Vector3(0, phi, -1/phi).normalized() * 0.8)
	points.append(Vector3(0, -phi, 1/phi).normalized() * 0.8)
	points.append(Vector3(0, -phi, -1/phi).normalized() * 0.8)
	
	return points

func create_d20_points() -> PackedVector3Array:
	var points = PackedVector3Array()
	var phi = (1 + sqrt(5)) / 2  # Golden ratio
	
	# Add vertices of an icosahedron
	points.append(Vector3(0, 1, phi).normalized() * 0.9)
	points.append(Vector3(0, 1, -phi).normalized() * 0.9)
	points.append(Vector3(0, -1, phi).normalized() * 0.9)
	points.append(Vector3(0, -1, -phi).normalized() * 0.9)
	
	points.append(Vector3(1, phi, 0).normalized() * 0.9)
	points.append(Vector3(1, -phi, 0).normalized() * 0.9)
	points.append(Vector3(-1, phi, 0).normalized() * 0.9)
	points.append(Vector3(-1, -phi, 0).normalized() * 0.9)
	
	points.append(Vector3(phi, 0, 1).normalized() * 0.9)
	points.append(Vector3(phi, 0, -1).normalized() * 0.9)
	points.append(Vector3(-phi, 0, 1).normalized() * 0.9)
	points.append(Vector3(-phi, 0, -1).normalized() * 0.9)
	
	return points

func add_dice_face_markers(mesh_instance, dice_type):
	# Add 3D text for face numbers (simplified version)
	match dice_type:
		"d6":
			# For d6, add numbers on each face
			for i in range(1, 7):
				var label_3d = Label3D.new()
				label_3d.text = str(i)
				label_3d.font_size = 64
				label_3d.modulate = Color.BLACK
				
				# Position based on face
				match i:
					1: label_3d.position = Vector3(0, -0.51, 0)  # Bottom
					2: label_3d.position = Vector3(0.51, 0, 0)   # Right
					3: label_3d.position = Vector3(0, 0, 0.51)   # Front
					4: label_3d.position = Vector3(0, 0, -0.51)  # Back
					5: label_3d.position = Vector3(-0.51, 0, 0)  # Left
					6: label_3d.position = Vector3(0, 0.51, 0)   # Top
				
				# Rotate label to face outward
				match i:
					1: label_3d.rotation_degrees = Vector3(90, 0, 0)
					2: label_3d.rotation_degrees = Vector3(0, -90, 0)
					3: label_3d.rotation_degrees = Vector3(0, 0, 0)
					4: label_3d.rotation_degrees = Vector3(0, 180, 0)
					5: label_3d.rotation_degrees = Vector3(0, 90, 0)
					6: label_3d.rotation_degrees = Vector3(-90, 0, 0)
				
				mesh_instance.add_child(label_3d)
		_:
			# For other dice types, we would add the appropriate number of faces
			# with correct positions and orientations
			pass

func add_face_detectors(die, dice_type):
	# Add invisible collision shapes to detect which face is up
	match dice_type:
		"d4":
			# Add 4 face detectors for tetrahedron
			for i in range(1, 5):
				add_face_detector(die, i, dice_type)
		"d6":
			# Add 6 face detectors for cube
			for i in range(1, 7):
				add_face_detector(die, i, dice_type)
		"d8":
			# Add 8 face detectors for octahedron
			for i in range(1, 9):
				add_face_detector(die, i, dice_type)
		"d10":
			# Add 10 face detectors
			for i in range(1, 11):
				add_face_detector(die, i, dice_type)
		"d12":
			# Add 12 face detectors
			for i in range(1, 13):
				add_face_detector(die, i, dice_type)
		"d20":
			# Add 20 face detectors
			for i in range(1, 21):
				add_face_detector(die, i, dice_type)

func add_face_detector(die, face_value, dice_type):
	var detector = Marker3D.new()
	detector.name = "Face_" + str(face_value)
	detector.set_meta("face_value", face_value)
	
	# Position detectors based on die type and face value
	match dice_type:
		"d4":
			# Position for tetrahedron faces
			match face_value:
				1: detector.position = Vector3(0, 0.5, 0.33)
				2: detector.position = Vector3(-0.433, -0.25, -0.25)
				3: detector.position = Vector3(0.433, -0.25, -0.25)
				4: detector.position = Vector3(0, -0.25, 0.5)
		"d6":
			# Position for cube faces
			match face_value:
				1: detector.position = Vector3(0, -0.6, 0)   # Bottom
				2: detector.position = Vector3(0.6, 0, 0)    # Right
				3: detector.position = Vector3(0, 0, 0.6)    # Front
				4: detector.position = Vector3(0, 0, -0.6)   # Back
				5: detector.position = Vector3(-0.6, 0, 0)   # Left
				6: detector.position = Vector3(0, 0.6, 0)    # Top
		"d8":
			# Position for octahedron faces (simplified)
			var angle = (face_value - 1) * PI / 4
			var x = 0.6 * cos(angle)
			var z = 0.6 * sin(angle)
			var y = face_value <= 4 ? 0.4 : -0.4
			detector.position = Vector3(x, y, z)
		"d10", "d12", "d20":
			# Simplified positioning for complex dice
			# In a real implementation, these would be precisely calculated
			var radius = 0.6
			var phi = 2 * PI * (face_value - 1) / DICE_TYPES[dice_type]["faces"]
			var theta = PI * (0.5 - ((face_value - 1) % 2) * 0.8)
			
			var x = radius * sin(theta) * cos(phi)
			var y = radius * cos(theta)
			var z = radius * sin(theta) * sin(phi)
			
			detector.position = Vector3(x, y, z)
	
	die.add_child(detector)extends Node3D

# Constants for dice types and physics
const DICE_TYPES = {
	"d4": {"mesh": "res://dice/d4.tscn", "faces": 4},
	"d6": {"mesh": "res://dice/d6.tscn", "faces": 6},
	"d8": {"mesh": "res://dice/d8.tscn", "faces": 8},
	"d10": {"mesh": "res://dice/d10.tscn", "faces": 10},
	"d12": {"mesh": "res://dice/d12.tscn", "faces": 12},
	"d20": {"mesh": "res://dice/d20.tscn", "faces": 20}
}

const DICE_SPAWN_HEIGHT = 5.0
const DICE_FORCE_MIN = 2.0
const DICE_FORCE_MAX = 5.0
const DICE_TORQUE_MIN = 2.0
const DICE_TORQUE_MAX = 5.0
const CAMERA_MOVE_SPEED = 0.1
const CAMERA_ZOOM_SPEED = 0.05
const CAMERA_ROTATE_SPEED = 0.01

# Node references
var camera
var table
var dice_container
var result_label
var modifier_input
var dice_counts = {}
var active_dice = []
var results_dict = {}

func _ready():
	# Setup the scene
	setup_environment()
	setup_table()
	setup_camera()
	setup_ui()
	
	# Initialize dice counts
	for dice_type in DICE_TYPES.keys():
		dice_counts[dice_type] = 0
		results_dict[dice_type] = []

func setup_environment():
	# Create environment with ambient light
	var world_environment = WorldEnvironment.new()
	var environment = Environment.new()
	environment.ambient_light_color = Color(0.5, 0.5, 0.5)
	environment.ambient_light_energy = 1.0
	world_environment.environment = environment
	add_child(world_environment)
	
	# Add directional light
	var light = DirectionalLight3D.new()
	light.transform.basis = Basis(Vector3(0.5, -0.7, 0.3).normalized(), PI/4)
	light.light_energy = 1.2
	add_child(light)
	
	# Create container for dice
	dice_container = Node3D.new()
	dice_container.name = "DiceContainer"
	add_child(dice_container)

func setup_table():
	# Create table with edges
	table = Node3D.new()
	table.name = "Table"
	add_child(table)
	
	# Add table surface
	var table_surface = StaticBody3D.new()
	var table_collision = CollisionShape3D.new()
	var table_shape = BoxShape3D.new()
	table_shape.size = Vector3(20, 1, 20)
	table_collision.shape = table_shape
	table_surface.add_child(table_collision)
	
	var table_mesh = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(20, 1, 20)
	table_mesh.mesh = box_mesh
	
	# Create material for table
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.4, 0.2)  # Dark green for the table
	table_mesh.material_override = material
	
	table_surface.add_child(table_mesh)
	table.add_child(table_surface)
	
	# Add table edges (walls)
	var wall_height = 2.0
	var wall_thickness = 0.5
	var table_size = 20.0
	
# Function to create a wall
func create_wall(size: Vector3, position: Vector3) -> StaticBody3D:
	var wall = StaticBody3D.new()
	var wall_collision = CollisionShape3D.new()
	var wall_shape = BoxShape3D.new()
	wall_shape.size = size
	wall_collision.shape = wall_shape
	wall.add_child(wall_collision)
	
	var wall_mesh = MeshInstance3D.new()
	var wall_box_mesh = BoxMesh.new()
	wall_box_mesh.size = size
	wall_mesh.mesh = wall_box_mesh
	
	var wall_material = StandardMaterial3D.new()
	wall_material.albedo_color = Color(0.3, 0.2, 0.1)  # Brown for the walls
	wall_mesh.material_override = wall_material
	
	wall.add_child(wall_mesh)
	wall.position = position
	return wall
	
	# Create the four walls
	var half_table = table_size / 2
	var wall_y_pos = wall_height / 2 + 0.5  # Position walls above table
	
	# North wall
	var north_wall = create_wall(
		Vector3(table_size + wall_thickness * 2, wall_height, wall_thickness),
		Vector3(0, wall_y_pos, -half_table - wall_thickness / 2)
	)
	table.add_child(north_wall)
	
	# South wall
	var south_wall = create_wall(
		Vector3(table_size + wall_thickness * 2, wall_height, wall_thickness),
		Vector3(0, wall_y_pos, half_table + wall_thickness / 2)
	)
	table.add_child(south_wall)
	
	# East wall
	var east_wall = create_wall(
		Vector3(wall_thickness, wall_height, table_size),
		Vector3(half_table + wall_thickness / 2, wall_y_pos, 0)
	)
	table.add_child(east_wall)
	
	# West wall
	var west_wall = create_wall(
		Vector3(wall_thickness, wall_height, table_size),
		Vector3(-half_table - wall_thickness / 2, wall_y_pos, 0)
	)
	table.add_child(west_wall)

func setup_camera():
	# Create camera with controls
	camera = Camera3D.new()
	camera.name = "DiceCamera"
	camera.position = Vector3(0, 15, 10)
	camera.rotation_degrees = Vector3(-60, 0, 0)
	camera.current = true
	add_child(camera)

func setup_ui():
	# Create UI canvas
	var canvas = CanvasLayer.new()
	add_child(canvas)
	
	# Create main container
	var main_container = Control.new()
	main_container.anchor_right = 1.0
	main_container.anchor_bottom = 1.0
	canvas.add_child(main_container)
	
	# Create result label at top
	result_label = Label.new()
	result_label.text = "No dice rolled yet"
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.anchor_right = 1.0
	result_label.offset_top = 20
	result_label.add_theme_font_size_override("font_size", 24)
	main_container.add_child(result_label)
	
	# Create right panel for dice controls
	var right_panel = Panel.new()
	right_panel.anchor_left = 0.8
	right_panel.anchor_right = 1.0
	right_panel.anchor_bottom = 1.0
	main_container.add_child(right_panel)
	
	# Create vertical container for dice buttons
	var vbox = VBoxContainer.new()
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.offset_left = 10
	vbox.offset_right = -10
	vbox.offset_top = 10
	vbox.offset_bottom = -10
	right_panel.add_child(vbox)
	
	# Add title
	var title = Label.new()
	title.text = "Dice Roller"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)
	
	# Add separator
	var separator1 = HSeparator.new()
	vbox.add_child(separator1)
	
	# Add modifier input
	var mod_hbox = HBoxContainer.new()
	vbox.add_child(mod_hbox)
	
	var mod_label = Label.new()
	mod_label.text = "Modifier:"
	mod_hbox.add_child(mod_label)
	
	modifier_input = SpinBox.new()
	modifier_input.min_value = -100
	modifier_input.max_value = 100
	modifier_input.value = 0
	mod_hbox.add_child(modifier_input)
	
	# Add separator
	var separator2 = HSeparator.new()
	vbox.add_child(separator2)
	
	# Add dice type selection and count
	for dice_type in DICE_TYPES.keys():
		var dice_hbox = HBoxContainer.new()
		vbox.add_child(dice_hbox)
		
		var dice_button = Button.new()
		dice_button.text = dice_type
		dice_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		dice_button.pressed.connect(_on_dice_button_pressed.bind(dice_type))
		dice_hbox.add_child(dice_button)
		
		var dice_count = SpinBox.new()
		dice_count.min_value = 0
		dice_count.max_value = 20
		dice_count.value = 0
		dice_count.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		dice_count.value_changed.connect(_on_dice_count_changed.bind(dice_type))
		dice_hbox.add_child(dice_count)
	
	# Add separator
	var separator3 = HSeparator.new()
	vbox.add_child(separator3)
	
	# Add roll all button
	var roll_all_button = Button.new()
	roll_all_button.text = "Roll All Selected"
	roll_all_button.pressed.connect(_on_roll_all_pressed)
	vbox.add_child(roll_all_button)
	
	# Add clear button
	var clear_button = Button.new()
	clear_button.text = "Clear Dice"
	clear_button.pressed.connect(_on_clear_pressed)
	vbox.add_child(clear_button)

func _on_dice_button_pressed(dice_type):
	# Roll a single die of selected type
	spawn_dice(dice_type, 1)

func _on_dice_count_changed(value, dice_type):
	dice_counts[dice_type] = int(value)

func _on_roll_all_pressed():
	# Roll all selected dice
	for dice_type in dice_counts.keys():
		if dice_counts[dice_type] > 0:
			spawn_dice(dice_type, dice_counts[dice_type])

func _on_clear_pressed():
	# Clear all dice from table
	for die in active_dice:
		die.queue_free()
	active_dice.clear()
	
	# Clear results
	for dice_type in results_dict.keys():
		results_dict[dice_type].clear()
	
	update_result_label()

func spawn_dice(dice_type, count):
	for i in range(count):
		# Create a proper die with faces
		var die = RigidBody3D.new()
		die.name = dice_type + str(active_dice.size())
		die.mass = 2.0
		die.physics_material_override = PhysicsMaterial.new()
		die.physics_material_override.bounce = 0.3
		die.physics_material_override.friction = 0.8
		
		# Add collision shape and mesh based on dice type
		var collision = CollisionShape3D.new()
		var mesh_instance = MeshInstance3D.new()
		var shape
		var mesh
		
		match dice_type:
			"d4":
				# Tetrahedron for d4
				shape = ConvexPolygonShape3D.new()
				var points = PackedVector3Array([
					Vector3(0, 1, 0),
					Vector3(-0.866, -0.5, -0.5),
					Vector3(0.866, -0.5, -0.5),
					Vector3(0, -0.5, 1)
				])
				shape.points = points
				
				# Create custom mesh for d4
				mesh = create_tetrahedron_mesh()
				
				# Add face markers
				add_dice_face_markers(mesh_instance, dice_type)
				
			"d6":
				# Cube for d6
				shape = BoxShape3D.new()
				shape.size = Vector3(1, 1, 1)
				
				mesh = BoxMesh.new()
				mesh.size = Vector3(1, 1, 1)
				
				# Add face markers
				add_dice_face_markers(mesh_instance, dice_type)
				
			"d8":
				# Octahedron for d8
				shape = ConvexPolygonShape3D.new()
				var points = PackedVector3Array([
					Vector3(0, 1, 0),
					Vector3(0, -1, 0),
					Vector3(1, 0, 0),
					Vector3(-1, 0, 0),
					Vector3(0, 0, 1),
					Vector3(0, 0, -1)
				])
				shape.points = points
				
				# Use sphere as placeholder (in real project, create proper octahedron)
				mesh = SphereMesh.new()
				mesh.radius = 0.7
				
				# Add face markers
				add_dice_face_markers(mesh_instance, dice_type)
				
			"d10":
				# Simplified d10 (should be pentagonal trapezohedron)
				shape = ConvexPolygonShape3D.new()
				var points = create_d10_points()
				shape.points = points
				
				# Use sphere as placeholder (in real project, create proper d10)
				mesh = SphereMesh.new()
				mesh.radius = 0.7
				
				# Add face markers
				add_dice_face_markers(mesh_instance, dice_type)
				
			"d12":
				# Simplified d12 (should be dodecahedron)
				shape = ConvexPolygonShape3D.new()
				var points = create_d12_points()
				shape.points = points
				
				# Use sphere as placeholder (in real project, create proper dodecahedron)
				mesh = SphereMesh.new()
				mesh.radius = 0.8
				
				# Add face markers
				add_dice_face_markers(mesh_instance, dice_type)
				
			"d20":
				# Simplified d20 (should be icosahedron)
				shape = ConvexPolygonShape3D.new()
				var points = create_d20_points()
				shape.points = points
				
				# Use sphere as placeholder (in real project, create proper icosahedron)
				mesh = SphereMesh.new()
				mesh.radius = 0.9
				
				# Add face markers
				add_dice_face_markers(mesh_instance, dice_type)
		
		collision.shape = shape
		die.add_child(collision)
		
		mesh_instance.mesh = mesh
		
		# Add material
		var material = StandardMaterial3D.new()
		var hue = randf_range(0.0, 1.0)
		material.albedo_color = Color.from_hsv(hue, 0.8, 0.9)
		mesh_instance.material_override = material
		
		die.add_child(mesh_instance)
		
		# Add face detectors to determine roll result
		add_face_detectors(die, dice_type)
		
		# Store dice type and faces for result calculation
		die.set_meta("dice_type", dice_type)
		die.set_meta("faces", DICE_TYPES[dice_type]["faces"])
		die.set_meta("is_rolling", true)
		
		# Position the die above the table with random offset
		var rand_x = randf_range(-5.0, 5.0)
		var rand_z = randf_range(-5.0, 5.0)
		die.position = Vector3(rand_x, DICE_SPAWN_HEIGHT, rand_z)
		
		# Apply random rotation
		die.rotation = Vector3(
			randf_range(0, PI * 2),
			randf_range(0, PI * 2),
			randf_range(0, PI * 2)
		)
		
		# Apply random initial force and torque
		var direction = Vector3(
			randf_range(-1.0, 1.0),
			randf_range(-0.2, -1.0),  # Mostly downward
			randf_range(-1.0, 1.0)
		).normalized()
		
		var force = direction * randf_range(DICE_FORCE_MIN, DICE_FORCE_MAX)
		die.apply_central_impulse(force)
		
		var torque = Vector3(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		).normalized() * randf_range(DICE_TORQUE_MIN, DICE_TORQUE_MAX)
		die.apply_torque_impulse(torque)
		
		# Connect signal to detect when the die stops
		die.sleeping_state_changed.connect(_on_die_stopped.bind(die))
		
		# Add die to scene and tracking
		dice_container.add_child(die)
		active_dice.append(die)

func _on_die_stopped(is_asleep, die):
	if is_asleep and die.get_meta("is_rolling"):
		die.set_meta("is_rolling", false)
		
		# Get result from face detectors
		var dice_type = die.get_meta("dice_type")
		var result = determine_dice_result(die, dice_type)
		
		# Store the result
		results_dict[dice_type].append(result)
		
		# Update the result display
		update_result_label()

func determine_dice_result(die, dice_type):
	# Get all face detectors of the die
	var face_detectors = []
	for child in die.get_children():
		if child.has_meta("face_value"):
			face_detectors.append(child)
	
	# Find which face is most upward (highest Y position)
	var highest_detector = null
	var highest_y = -INF
	
	for detector in face_detectors:
		var global_pos = detector.global_position
		if global_pos.y > highest_y:
			highest_y = global_pos.y
			highest_detector = detector
	
	# Return the value of the highest face
	if highest_detector:
		return highest_detector.get_meta("face_value")
	else:
		# Fallback to random if no detector is found (shouldn't happen)
		var faces = die.get_meta("faces")
		return randi_range(1, faces)

func update_result_label():
	var total = 0
	var result_text = ""
	var modifier = int(modifier_input.value)
	
	# Process each dice type
	for dice_type in results_dict.keys():
		var results = results_dict[dice_type]
		for result in results:
			if result_text != "":
				result_text += "+"
			result_text += str(result) + "(" + dice_type + ")"
			total += result
	
	# Add modifier if not zero
	if modifier != 0:
		if modifier > 0:
			result_text += "+" + str(modifier) + "(mod)"
		else:
			result_text += str(modifier) + "(mod)"
		total += modifier
	
	# Set final result text
	if result_text != "":
		result_text += "=" + str(total)
		result_label.text = result_text
	else:
		result_label.text = "No dice rolled yet"

func _process(delta):
	# Handle camera controls
	handle_camera_input(delta)

func _input(event):
	# Camera controls for zooming with scroll wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.position += camera.transform.basis.z * CAMERA_ZOOM_SPEED
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.position -= camera.transform.basis.z * CAMERA_ZOOM_SPEED

func handle_camera_input(delta):
	# Get input strength for smoother movement
	var right = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var forward = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	
	# Move camera based on local camera directions (relative to camera orientation)
	if right != 0 or forward != 0:
		var movement = Vector3.ZERO
		# Move right/left along camera's local X axis
		movement += camera.transform.basis.x * right * CAMERA_MOVE_SPEED
		# Move forward/back along camera's local Z axis (XZ plane only)
		var forward_dir = camera.transform.basis.z
		forward_dir.y = 0  # Keep movement on XZ plane
		forward_dir = forward_dir.normalized()
		movement -= forward_dir * forward * CAMERA_MOVE_SPEED
		
		camera.position += movement
	
	# Vertical movement (up/down) independent of camera orientation
	if Input.is_action_pressed("ui_page_up"):
		camera.position.y += CAMERA_ZOOM_SPEED
	if Input.is_action_pressed("ui_page_down"):
		camera.position.y -= CAMERA_ZOOM_SPEED
	
	# Camera rotation with middle mouse button
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		var mouse_motion = Input.get_last_mouse_velocity()
		if mouse_motion.length() > 0:
			camera.rotation.x -= mouse_motion.y * CAMERA_ROTATE_SPEED * delta
			camera.rotation.y -= mouse_motion.x * CAMERA_ROTATE_SPEED * delta
			
			# Clamp vertical rotation to avoid flipping
			camera.rotation.x = clamp(camera.rotation.x, -PI/2 + 0.1, PI/2 - 0.1)

# Note: This script assumes you have properly set up the input map
# for UI controls and mouse buttons in your Godot project settings
