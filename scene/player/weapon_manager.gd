extends Node3D

var all_weapons = {
	
}

var weapons = {
	
}

var hud

var current_weapon
var current_weapon_slot = "Empty"

var changing_weapon = false
var unequipped_weapon = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hud = owner.get_node("HUD")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
