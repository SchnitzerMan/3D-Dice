extends Node3D

@onready var roll_button = $CanvasLayer/RollD6
var dice_scene = preload("res://D6_Prefab.tscn")
var current_dice: RigidBody3D = null

func _ready():
	roll_button.pressed.connect(_on_roll_button_pressed)

func _on_roll_button_pressed():
	# Remove existing dice if any
	if current_dice and is_instance_valid(current_dice):
		current_dice.queue_free()

	# Instantiate dice
	current_dice = dice_scene.instantiate() as RigidBody3D
	add_child(current_dice)

	# Random spawn height (Y between 3–5)
	var y = randf_range(3.0, 5.0)
	current_dice.global_position = Vector3(0, y, 0)

	# Random initial rotation
	var x_rotation = randi_range(0, 360)
	var y_rotation = randi_range(0, 360)
	var z_rotation = randi_range(0, 360)
	
	current_dice.rotation_degrees = Vector3(
		x_rotation,
		y_rotation,
		z_rotation
	)

	
