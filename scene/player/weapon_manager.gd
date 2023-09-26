extends Node3D
class_name WeaponManager

enum EWeaponSlot {
	Empty,
	Primary,
	Secondary
}

var slots_count: int = 3

var all_weapons = {}
var weapons = {}

var hud
var current_weapon: Weapon
var current_weapon_slot: EWeaponSlot = EWeaponSlot.Empty

var changing_weapon: bool = false
var unequipped_weapon: bool = false

@onready var ray: RayCast3D = get_node("../Camera3D/RayCast3D")

# Called when the node enters the scene tree for the first time.
func _ready():
	print("WeaponManager initializing. owner: %s" % owner)
	
	hud = owner.get_node("HUD")
	ray.add_exception(owner)
	
	all_weapons = {
		"Unarmed": preload("res://scene/weapons/unarmed.tscn"),
		"Pistol_A": preload("res://scene/weapons/pistol_a.tscn"),
		"Rifle_A": preload("res://scene/weapons/rifle_a.tscn"),
		"Pistol_B": preload("res://scene/weapons/pistol_b1.tscn"),
		"Rifle_B": preload("res://scene/weapons/rifle_b1.tscn")
	}
	
	weapons = {
		EWeaponSlot.Empty: all_weapons["Unarmed"].instantiate(),
		EWeaponSlot.Primary: $Pistol,
		EWeaponSlot.Secondary: $Rifle
	}
	
	for w in weapons:
		if (weapons[w] != null):
			weapons[w].weapon_manager = self
			weapons[w].player = owner
			weapons[w].visible = false
			weapons[w].ray = ray
		
	current_weapon = weapons[EWeaponSlot.Empty]
	change_weapon(EWeaponSlot.Empty)
	
	set_process(false)

func fire():
	if not changing_weapon:
		current_weapon.fire()
		
func fire_stop():
	current_weapon.fire_stop()
	
func reload():
	if not changing_weapon:
		current_weapon.reload()
	
func add_ammo(amount: int = 0)-> bool: 
	if current_weapon == null || amount <= 0:
		return false
	
	current_weapon.update_ammo(Weapon.EAmmoUpdateType.Add, amount)
	return true

func _process(delta):
	if unequipped_weapon == false:
		if current_weapon.is_unequip_finished() == false:
			return
			
		unequipped_weapon = true
		current_weapon = weapons[current_weapon_slot]
		current_weapon.equip()
		
	if current_weapon.is_equip_finished() == false:
		return
		
	changing_weapon = false
	set_process(false)

func change_weapon(new_weapon_slot: EWeaponSlot):
	if (new_weapon_slot == current_weapon_slot):
		current_weapon.update_ammo()
		return
	
	if weapons[new_weapon_slot] == null:
		return
	
	current_weapon_slot = new_weapon_slot
	changing_weapon = true
	
	weapons[current_weapon_slot].update_ammo()
	
	if current_weapon != null:
		unequipped_weapon = false
		current_weapon.unequip()
		
	
	set_process(true)
	
func next_weapon():
	var new_weapon_slot: EWeaponSlot = (current_weapon_slot + 1) % slots_count;
	
	change_weapon(new_weapon_slot)

func prev_weapon():
	var new_weapon_slot: EWeaponSlot = current_weapon_slot - 1
	if (new_weapon_slot < 0):
		new_weapon_slot = slots_count - 1
	
	change_weapon(new_weapon_slot)
	
	
func update_hud(weapon_data):
	hud.update_weapon_ui(weapon_data, str(current_weapon_slot + 1))
