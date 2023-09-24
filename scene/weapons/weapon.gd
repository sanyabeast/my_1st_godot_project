extends Node3D
class_name Weapon

var weapon_manager: WeaponManager
var player: Player
var animation_player: AnimationPlayer

var is_equipped: bool = false
var is_firing: bool = false
var is_reloading: bool = false

@export var weapon_name = "Weapon"

@export var equip_speed: float = 1.0
@export var unequip_speed: float = 1.0

func equip() -> void:
	print("equipping %s" % [weapon_name])
	if animation_player == null: 
		show_weapon()
		on_animation_finished("Equip")
		return
	animation_player.play("Equip", -1.0, equip_speed)
	update_ammo()

func unequip() -> void:
	print("unequipping %s" % [weapon_name])
	if animation_player == null: 
		hide_weapon()
		on_animation_finished("Unequip")
		return
	animation_player.play("Unequip", -1.0, unequip_speed)
	
func show_weapon():
	visible = true
	
func hide_weapon():
	visible = false

func is_equip_finished()-> bool:
	if is_equipped:
		return true
	else:
		return false

func is_unequip_finished()-> bool:
	if is_equipped:
		return false
	else:
		return true

func on_animation_finished(anim_name: String)->void:
	print("animation finished %s" %[anim_name])
	match anim_name:
		"Unequip":
			is_equipped = false
		"Equip":
			is_equipped = true

func update_ammo(action := "Refresh"):
	var weapon_data = {
		"Name": weapon_name
	}
	
	weapon_manager.update_hud(weapon_data)


func _ready():
	animation_player = $AnimationPlayer
	if animation_player != null:
		animation_player.connect("animation_finished", on_animation_finished)
	else:
		print("weapon has no animation player - %s" % [weapon_name])
	
