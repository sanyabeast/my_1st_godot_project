extends Node3D
class_name WeaponManager

var all_weapons = {}
var weapons = {}

var hud

var current_weapon
var current_weapon_slot = "Empty"

var changing_weapon = false
var unequipped_weapon = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hud = owner.get_node("HUD")
	all_weapons = {
		"Unarmed": preload("res://scene/weapons/unarmed.tscn"),
		"Pistol_A": preload("res://scene/weapons/pistol_a.tscn"),
		"Rifle_A": preload("res://scene/weapons/rifle_a.tscn")
	}
	
	weapons = {
		"Empty": $Unarmed,
		"Primary": $Pistol_A,
		"Secondary": $Rifle_A
	}
	
	for w in weapons:
		weapons[w].weapon_manager = self
		weapons[w].player = owner
		weapons[w].visible = false
		
	current_weapon = weapons["Empty"]
	change_weapon("Empty")
	
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

func change_weapon(new_weapon_slot):
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
	
func update_hud(weapon_data):
	var weapon_slot = "1"
	
	match current_weapon_slot:
		"Empty":
			weapon_slot = "1"
		"Primary":
			weapon_slot = "2"
		"Secondary":
			weapon_slot = "3"

	hud.update_weapon_ui(weapon_data, weapon_slot)
