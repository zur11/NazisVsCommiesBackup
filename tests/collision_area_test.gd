extends Node2D

@onready var _blast_collision_shape : CollisionShape2D = $%BlastCollisionShape

func _ready():
	printt("Collision Shape Initial size: ", _blast_collision_shape.shape.size)
	
	_blast_collision_shape.shape.size = Vector2(500, 500)
	
	printt("Collision Shape Final size: ", _blast_collision_shape.shape.size)

func _on_blast_area_body_shape_entered(body_rid:RID, body:Node2D, body_shape_index:int, local_shape_index:int):
	printt(body)
