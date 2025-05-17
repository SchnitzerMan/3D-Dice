extends Camera3D

@export var target_path: NodePath
var target: Node3D

func _ready():
	target = get_node(target_path)
func _process(delta):
	if target:
		global_position = target.global_position + Vector3(0, 6, 8)
		global_rotation = target.global_rotation + Vector3(-28, 0, 0)
		look_at(target.global_position, Vector3.UP)
