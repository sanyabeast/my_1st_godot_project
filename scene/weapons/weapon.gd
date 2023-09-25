extends Node3D
# Define the Weapon class that can be used elsewhere in the project.
class_name Weapon

# Variables to store references to other nodes or classes.
var weapon_manager: WeaponManager
var player: Player
var animation_player: AnimationPlayer

# State variables to track weapon's status.
var is_equipped: bool = false
var is_firing: bool = false
var is_reloading: bool = false

# Exported variables can be set in the Godot Editor.
@export var weapon_name = "Weapon"

# Speed at which weapon gets equipped/unequipped.
@export var equip_speed: float = 1.0
@export var unequip_speed: float = 1.0

# Equip the weapon. This function will handle the logic when the player equips a weapon.
func equip() -> void:
	print("equipping %s" % [weapon_name])
	# Check if there's no animation for equipping, in which case show the weapon immediately.
	if animation_player == null: 
		show_weapon()
		on_animation_finished("Equip")
		return
	# If there's an animation player, play the "Equip" animation.
	animation_player.play("Equip", -1.0, equip_speed)
	update_ammo()

# Unequip the weapon.
func unequip() -> void:
	print("unequipping %s" % [weapon_name])
	# Check if there's no animation for unequipping, in which case hide the weapon immediately.
	if animation_player == null: 
		hide_weapon()
		on_animation_finished("Unequip")
		return
	# If there's an animation player, play the "Unequip" animation.
	animation_player.play("Unequip", -1.0, unequip_speed)

# Function to make the weapon visible in the scene.
func show_weapon():
	visible = true

# Function to hide the weapon from the scene.
func hide_weapon():
	visible = false

# Check if equip action is finished.
func is_equip_finished()-> bool:
	return is_equipped

# Check if unequip action is finished.
func is_unequip_finished()-> bool:
	return not is_equipped

# Callback for when any weapon-related animation finishes.
func on_animation_finished(anim_name: String)->void:
	print("animation finished %s" %[anim_name])
	match anim_name:
		"Unequip":
			is_equipped = false
		"Equip":
			is_equipped = true

# Update the ammo count on the HUD.
func update_ammo(action := "Refresh"):
	var weapon_data = {
		"Name": weapon_name
	}
	weapon_manager.update_hud(weapon_data)

# This function runs once when the node enters the scene.
func _ready():
	# Get a reference to the AnimationPlayer node.
	animation_player = $AnimationPlayer
	# If the weapon has an AnimationPlayer, connect its "animation_finished" signal to our custom function.
	if animation_player != null:
		animation_player.connect("animation_finished", on_animation_finished)
	else:
		print("weapon has no animation player - %s" % [weapon_name])
