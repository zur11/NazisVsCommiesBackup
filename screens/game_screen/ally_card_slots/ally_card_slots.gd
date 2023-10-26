class_name AllyCardSlots extends VBoxContainer

@export var ally_slot_texture : Texture
var available_ally_slots : int : set = _set_available_ally_slots
var ally_slots_global_positions : Array[Vector2]

func toogle_ally_slot_visibility(slot_index:int, slot_visible:bool):
	var card_slot : TextureRect = self.get_child(slot_index)
	var visible_color := Color(1,1,1,1)
	var invisible_color := Color(1,1,1,0)
	
	if slot_visible:
		card_slot.modulate = visible_color
	else:
		card_slot.modulate = invisible_color

func _set_available_ally_slots(new_value:int):
	available_ally_slots = new_value
	
	_add_available_ally_slots()

func _add_available_ally_slots():
	if self.get_child_count() != 0:
		for child in self.get_children():
			child.queue_free()
	
#	await get_tree().process_frame
	
	for ii in available_ally_slots:
		var ally_slot := TextureRect.new()
		ally_slot.texture = ally_slot_texture
		self.add_child(ally_slot)
		await get_tree().create_timer(0.1).timeout
		ally_slots_global_positions.append(ally_slot.global_position)
#		printt("ally slot global position: ", ally_slot.global_position)
