extends Node3D

const Rules = preload("res://scripts/rules.gd")
var rules = Rules.new()
var gaze := 0.2

@onready var walker: CharacterBody3D = $Walker
@onready var gaze_pivot: Node3D = $Walker/GazePivot

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
	if get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		rules.release_gaze()
	elif Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if not rules.gaze_accepted(gaze):
		push_error("Gaze amount is outside the accepted range.")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if not rules.gaze_accepted(gaze):
			return
		walker.rotate_y(-event.relative.x * gaze * 0.01)
		gaze_pivot.rotate_x(-event.relative.y * gaze * 0.01)
		gaze_pivot.rotation.x = clampf(gaze_pivot.rotation.x, deg_to_rad(-80.0), deg_to_rad(80.0))

func _physics_process(delta: float) -> void:
	var wish := Vector2(
		Input.get_action_strength("stride_east") - Input.get_action_strength("stride_west"),
		Input.get_action_strength("stride_south") - Input.get_action_strength("stride_north")
	)
	var step := rules.planar_step(wish, Input.is_key_pressed(KEY_SHIFT))
	var facing := walker.global_transform.basis
	var planar := facing * Vector3(step.x, 0, step.y)
	walker.velocity.x = planar.x
	walker.velocity.z = planar.z
	var grounded := walker.is_on_floor()
	if Input.is_action_just_pressed("leap"):
		walker.velocity.y = rules.leap_push(walker.velocity.y, grounded)
	if not grounded:
		walker.velocity.y -= 12.0 * delta
	walker.move_and_slide()
	var airborne := not walker.is_on_floor()
	if Input.is_action_pressed("primary") and rules.crouch_height(airborne):
		walker.scale.y = 0.6
	elif not Input.is_action_pressed("primary"):
		walker.scale.y = 1.0
	if walker.global_position.z < -8.0 and Input.is_action_just_pressed("primary"):
		if rules.crouch_height(airborne) and rules.may_ramp(airborne):
			_go("res://scenes/ramp.tscn")

func _go(next_path: String) -> void:
	get_tree().change_scene_to_file(next_path)
