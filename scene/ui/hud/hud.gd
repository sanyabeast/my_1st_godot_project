extends Control

func update_weapon_ui(weapon_data, weapon_slot):
	$Background/WeaponUI.text = weapon_data["Name"] + ": " + "0/0"
	$Background/Display/WeaponSlotUI.text = weapon_slot
