extends CharacterBody3D
class_name Player

const MOUSE_SENSITIVITY = 0.1

@onready var camera = $CameraRoot/Camera3D
@onready var weapon_manager: WeaponManager = $CameraRoot/Weapons

var current_vel = Vector3.ZERO
var dir = Vector3.ZERO

const SPEED = 10
const SPRINT_SPEED = 20
const ACCEL = 15.0

const GRAVITY = -40
const JUMP_SPEED = 15
var jump_counter = 0
const AIR_ACCEL = 9.0

func _ready():
	print("ready")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		# rotates the view vertically
		$CameraRoot.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		$CameraRoot.rotation_degrees.x = clamp($CameraRoot.rotation_degrees.x, -75, 75)
		# rotates the view horizontally
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))

func _process(delta):
	window_activity()
	
func _physics_process(delta):
	process_movement(delta)
	process_weapons(delta)

func process_movement(delta):
	dir = Vector3.ZERO

	if Input.is_action_pressed("forward"):
		dir -= camera.global_transform.basis.z
	if Input.is_action_pressed("backward"):
		dir += camera.global_transform.basis.z
	if Input.is_action_pressed("right"):
		dir += camera.global_transform.basis.x
	if Input.is_action_pressed("left"):
		dir -= camera.global_transform.basis.x

	
	var speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED
	var target_vel = dir * speed
	var accel = ACCEL if is_on_floor() else AIR_ACCEL
	
	dir = dir.normalized()
	
	velocity.y += GRAVITY * delta
	
	if is_on_floor():
		jump_counter = 0
		
	if Input.is_action_just_pressed("jump") and jump_counter < 2:
		jump_counter += 1
		velocity.y = JUMP_SPEED
		

	velocity.x = lerp(velocity.x, target_vel.x, accel * delta)
	velocity.z = lerp(velocity.z, target_vel.z, accel * delta)
	
	move_and_slide()

func process_weapons(delta):
	if Input.is_action_just_pressed("empty"):
		weapon_manager.change_weapon("Empty")
	if Input.is_action_just_pressed("primary"):
		weapon_manager.change_weapon("Primary")
	if Input.is_action_just_pressed("secondary"):
		weapon_manager.change_weapon("Secondary")

func window_activity():
	if Input.is_action_just_pressed("ui_cancel"):
		if (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
