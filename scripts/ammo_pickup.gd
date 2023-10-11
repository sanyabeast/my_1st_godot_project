class_name AmmoPickup

extends Area3D

@export var ammo: int = 10 


func _on_body_entered(body):
	if body is Player:
		var result = body.weapon_manager.add_ammo(ammo)
		
		if result:
			queue_free()
