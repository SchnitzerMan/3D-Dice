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

	# One-time burst of random velocity (angled downward)
	var angle = randf_range(0.0, TAU)
	var direction = Vector3(cos(angle), 0, sin(angle)).normalized()
	var speed = randf_range(3.0, 7.0)
	var downward = -randf_range(4.0, 8.0)

	current_dice.linear_velocity = direction * speed + Vector3(0, downward, 0)

	# One-time burst of random spin
	var torque = Vector3(
		randf_range(-20.0, 20.0),
		randf_range(-20.0, 20.0),
		randf_range(-20.0, 20.0)
	)
	current_dice.apply_torque_impulse(torque)
