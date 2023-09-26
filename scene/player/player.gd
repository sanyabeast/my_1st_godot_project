extends CharacterBody3D
class_name Player

const MOUSE_SENSITIVITY = 0.1

@onready var camera = $CameraRoot/Camera3D
@onready var weapon_manager: WeaponManager = $CameraRoot/Weapons

var current_vel = Vector3.ZERO
var dir = Vector3.ZERO

const SPEED: float = 7
const SPRINT_SPEED: float = 12
const ACCEL: float = 5

const GRAVITY: float = -36
const JUMP_SPEED: float = 14
const JUMP_SPEED_FADE: float = 0.3
var jump_counter: int = 0
const AIR_ACCEL: float = 0.1

var _current_acceleration: float = 0.0
var _current_acceleration_alpha: float = 0.25

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
		
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP:
					weapon_manager.next_weapon()
				MOUSE_BUTTON_WHEEL_DOWN:
					weapon_manager.prev_weapon()
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

	
	var speed = SPRINT_SPEED if (Input.is_action_pressed("sprint") and is_on_floor()) else SPEED
	var target_vel = dir * speed
	var accel = ACCEL if is_on_floor() else AIR_ACCEL
	
	_current_acceleration = lerp(_current_acceleration, accel, _current_acceleration_alpha * delta)
	
	dir = dir.normalized()
	
	velocity.y += GRAVITY * delta
	
	if is_on_floor():
		jump_counter = 0
		
	if Input.is_action_just_pressed("jump") and jump_counter < 2:
		var jump_speed = lerp(JUMP_SPEED, JUMP_SPEED / (jump_counter + 1), JUMP_SPEED_FADE)
		jump_counter += 1
		velocity.y = jump_speed
		

	velocity.x = lerp(velocity.x, target_vel.x, _current_acceleration * delta)
	velocity.z = lerp(velocity.z, target_vel.z, _current_acceleration * delta)
	
	move_and_slide()

func process_weapons(delta):
	if Input.is_action_just_pressed("empty"):
		weapon_manager.change_weapon(WeaponManager.EWeaponSlot.Empty)
	if Input.is_action_just_pressed("primary"):
		weapon_manager.change_weapon(WeaponManager.EWeaponSlot.Primary)
	if Input.is_action_just_pressed("secondary"):
		weapon_manager.change_weapon(WeaponManager.EWeaponSlot.Secondary)
		
	if Input.is_action_just_pressed("Fire"):
		weapon_manager.fire()
	if Input.is_action_just_released("Fire"):
		weapon_manager.fire_stop()
		
	if Input.is_action_just_pressed("Reload"):
		weapon_manager.reload()

func window_activity():
	if Input.is_action_just_pressed("ui_cancel"):
		if (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
