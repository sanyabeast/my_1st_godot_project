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
var current_weapon
var current_weapon_slot: EWeaponSlot = EWeaponSlot.Empty

var changing_weapon: bool = false
var unequipped_weapon: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hud = owner.get_node("HUD")
	all_weapons = {
		"Unarmed": preload("res://scene/weapons/unarmed.tscn"),
		"Pistol_A": preload("res://scene/weapons/pistol_a.tscn"),
		"Rifle_A": preload("res://scene/weapons/rifle_a.tscn")
	}
	
	weapons = {
		EWeaponSlot.Empty: all_weapons["Unarmed"].instantiate(),
		EWeaponSlot.Primary: $Pistol_A,
		EWeaponSlot.Secondary: $Rifle_A
	}
	
	for w in weapons:
		if (weapons[w] != null):
			weapons[w].weapon_manager = self
			weapons[w].player = owner
			weapons[w].visible = false
		
	current_weapon = weapons[EWeaponSlot.Empty]
	change_weapon(EWeaponSlot.Empty)
	
	set_process(false)

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
