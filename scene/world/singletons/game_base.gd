class_name GameBase

extends Node

func instantiate_node(packed_scene: PackedScene, pos: Vector3 = Vector3.ZERO, parent: Node = null):
	if packed_scene != null:
		var clone = packed_scene.instantiate()
		var root = get_tree().root
		
		if parent == null:
			parent = root.get_child(root.get_child_count() - 1)

		parent.add_child(clone)

		if pos != null:
			clone.global_transform.origin = pos
			
		return clone
	else:
		print("Failed to instatiate packed scene, no packed scene provided")

func _init():
	print("GameBase inited")
