extends Node3D
# Define the Weapon class that can be used elsewhere in the project.
class_name Weapon

enum EAmmoUpdateType {
	Refresh,
	Consume,
	Reload,
	Add
}

# Variables to store references to other nodes or classes.
var weapon_manager: WeaponManager
var player: Player
var animation_player: AnimationPlayer
var ray: RayCast3D = null

# State variables to track weapon's status.
var is_equipped: bool = false
var is_firing: bool = false
var is_reloading: bool = false
var was_firing_before_reload: bool = false

@export var damage = 10
@export var ammo_in_mag = 15
@export var extra_ammo = 30
@export var fire_rate = 1.0

var mag_size = ammo_in_mag

@export var impact_effect: PackedScene
@export var muzzle_flash_path: NodePath
@onready var muzzle_flash: GPUParticles3D = get_node(muzzle_flash_path)

# Exported variables can be set in the Godot Editor.
@export var weapon_name = "Weapon"
@export var weapon_image: Texture


# Speed at which weapon gets equipped/unequipped.
@export var equip_speed: float = 1.0
@export var unequip_speed: float = 1.0
@export var reload_speed: float = 1.0

func fire():
	if not is_reloading:
		if ammo_in_mag > 0:
			if not is_firing:
				is_firing = true
				if (animation_player != null):
					animation_player.get_animation("Fire").loop_mode = Animation.LOOP_LINEAR
					animation_player.play("Fire", -1.0, fire_rate)
				
			return
		elif is_firing:
			fire_stop()

func fire_stop(dont_reset_firing_before_reload:= false):
	is_firing = false
	
	if dont_reset_firing_before_reload == false:
		was_firing_before_reload = false
		
	if animation_player != null:
		animation_player.get_animation("Fire").loop_mode = Animation.LOOP_NONE

func fire_bullet():
	if ammo_in_mag > 0:
		if muzzle_flash != null:
			muzzle_flash.emitting = true
			
		update_ammo(EAmmoUpdateType.Consume)
		ray.force_raycast_update()
		
		if ray.is_colliding():
			if impact_effect != null:
				var impact: GPUParticles3D = game_base.instantiate_node(impact_effect, ray.get_collision_point())
				impact.emitting = true
	else:
		was_firing_before_reload = is_firing
		fire_stop(true)
		reload()
	

func reload():
	if ammo_in_mag < mag_size and extra_ammo > 0:
#		is_firing = false;
		animation_player.play("Reload", -1.0, reload_speed)
		is_reloading = true

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
	is_reloading = false
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
		"Reload":
			is_reloading = false
			update_ammo(EAmmoUpdateType.Reload)
			print("Was firing before reload: %s" % was_firing_before_reload)
			if was_firing_before_reload:
				fire()

# Update the ammo count on the HUD.
func update_ammo(action := EAmmoUpdateType.Refresh, additional_ammo: int = 0):
	match action:
		EAmmoUpdateType.Consume:
			ammo_in_mag -= 1
		EAmmoUpdateType.Reload:
			var ammo_needed = mag_size - ammo_in_mag
			
			if extra_ammo > ammo_needed:
				ammo_in_mag = mag_size
				extra_ammo -= ammo_needed
			else:
				ammo_in_mag += extra_ammo
				extra_ammo = 0
		EAmmoUpdateType.Add: 
			extra_ammo += additional_ammo
	
	var weapon_data = {
		"Name": weapon_name,
		"Image": weapon_image,
		"Ammo": str(ammo_in_mag),
		"ExtraAmmo": str(extra_ammo)
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
