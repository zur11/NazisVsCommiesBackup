class_name Cell extends TextureButton

var is_occupied : bool

#var is_empty: bool = true : get = _get_is_empty
#
#func _get_is_empty() -> bool:
#	if !$Area2D.has_overlapping_bodies():
#		return true
#	else:
#		return false
