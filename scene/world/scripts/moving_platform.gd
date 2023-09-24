extends StaticBody3D

@export var point_A: Vector3
@export var point_B: Vector3
@export var speed = 1.0

var direction: int = 1  # This will be used to determine if we're moving towards point A or B

func _ready():
	position = point_A  # Start at point A

func _physics_process(delta):
	# Calculate the target point based on the current direction
	var target = point_B if direction == 1 else point_A

	# Calculate the move vector
	var move_vec = (target - position).normalized() * speed * delta

	# Check if we're about to overshoot our target
	if move_vec.length() > position.distance_to(target):
		position = target
		direction *= -1  # Reverse direction
	else:
		position += move_vec
