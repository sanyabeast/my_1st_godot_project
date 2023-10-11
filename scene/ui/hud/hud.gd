extends Control

var weapon_ui
var health_ui
var display_ui: TextureRect
var slot_ui

func _enter_tree():
	weapon_ui = $Background/WeaponUI
	health_ui = $Background/HealthUI
	display_ui = $Background/Display/TextureRect
	slot_ui = $Background/Display/WeaponSlotUI

func update_weapon_ui(weapon_data, weapon_slot):
	weapon_ui.text = weapon_data["Name"] + ": " + "%s/%s" % [weapon_data["Ammo"], weapon_data["ExtraAmmo"]]
	display_ui.texture = weapon_data["Image"]
	slot_ui.text = weapon_slot
	
