extends StaticBody3D


# Parameters to control the movement
@export var amplitude: float = 0.5  # The height of the movement
@export var frequency: float = 0.5   # The speed of the movement

# Record the original position
var original_position: Vector3

func _ready():
	# Save the original position of the node
	original_position = position

func _process(delta):
	# Calculate the new Y position using the sine function
	var new_y = original_position.y + amplitude * sin(Time.get_ticks_msec() * 0.001 * frequency * 2 * PI)
	
	# Set the new position
	position = Vector3(original_position.x, new_y, original_position.z)
