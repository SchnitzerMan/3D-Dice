extends CollisionShape3D

@export var radius := 4.0
@export var wall_count := 16
@export var wall_size := Vector3(0.2, 1.0, 0.5)

func _ready():
	for i in range(wall_count):
		var angle = (i / float(wall_count)) * TAU
		var wall = StaticBody3D.new()
		var shape = CollisionShape3D.new()
		var box = BoxShape3D.new()
		box.size = wall_size
		shape.shape = box
		wall.add_child(shape)
		
		var x = radius * cos(angle)
		var z = radius * sin(angle)
		wall.transform.origin = Vector3(x, wall_size.y / 2, z)
		wall.look_at(Vector3(0, wall.transform.origin.y, 0), Vector3.UP)
		
		add_child(wall)
