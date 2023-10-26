class_name ShieldSoldier extends ShooterAlly


@onready var _shield : SovietShield = $Shield 


func _set_initial_items():
	_items.append(_shield)

func _connect_items_signals():
	if _items.size() != 0:
		for item in _items:
			if item.occupies_cell:
				item.item_destroyed.connect(_on_cell_ocuppant_item_destroyed)

func _on_cell_ocuppant_item_destroyed(item:GameCharacterItem):
	_items.erase(item)
	cell_occupant_item_destroyed.emit(assigned_cell)

func set_ally_items_collision_settings(ally_collision_layer: int, ally_collision_mask:int):
	if _items.size() == 0: return
	
	for item in _items:
		item.set_collision_layer_value(ally_collision_layer, true)
		item.set_collision_mask_value(ally_collision_mask, true)


