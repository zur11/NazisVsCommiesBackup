class_name TerrainGrid extends GridContainer

signal cell_pressed(cell : Cell)
signal coin_picked_up(coin_value:int)
signal coin_for_cell_requested(falling_coin : RubleCoin, landing_cell : Cell)
signal ally_for_cell_requested(falling_ally:Ally, landing_cell : Cell)

const _COIN_SCENE_PATH : String = "res://game_objects/components/ruble_coin/ruble_coin.tscn"

var _enabled_cells : Array[Cell]
var _coin_landing_cells : Array[Cell]
var coin_dropping_rate : MinMaxIntRate : set = _set_coin_dropping_rate


func set_enabled_cells(playable_rows:int):
	match playable_rows:
		5:
			for cell in get_children() as Array[Cell]:
				_enabled_cells.append(cell)
		3:
			for cell in get_children() as Array[Cell]:
				if not cell.name.begins_with("Row1") and not cell.name.begins_with("Row5"):
					_enabled_cells.append(cell)
		1:
			for cell in get_children() as Array[Cell]:
				if cell.name.begins_with("Row3"):
					_enabled_cells.append(cell)
	
	_connect_cells_signals()

func _connect_cells_signals():
	for cell in _enabled_cells:
		cell.pressed.connect(_on_cell_pressed.bind(cell))

func _set_coin_dropping_rate(new_value : MinMaxIntRate):
	coin_dropping_rate = new_value
	_start_coin_landing_on_cells_process()

func _start_coin_landing_on_cells_process():
	var coin_drop_timer := Timer.new()
	coin_drop_timer.name = "CoinDropTimer"
	_set_coin_landing_cells()
	self.add_child(coin_drop_timer)
	coin_drop_timer.connect("timeout", _on_coin_drop_timer_time_up)
	coin_drop_timer.one_shot = true
	coin_drop_timer.wait_time = _get_coin_drop_wait_time()
	coin_drop_timer.start()
	
func _set_coin_landing_cells():
	for cell in get_children() as Array[Cell]:
		if cell is Cell and not cell.name.begins_with("Row1") and not cell.name.begins_with("Row2"):
			_coin_landing_cells.append(cell)


func cell_is_available_for_selected_ally(cell:Cell, ally:PackedScene) -> bool:
	var instantiated_ally : Ally  = ally.instantiate() as Ally
	var adjacent_cell : Cell = _get_right_adjacent_cell(cell)
	
	if adjacent_cell != null and adjacent_cell.is_occupied and instantiated_ally.occupies_two_cells:
		instantiated_ally.queue_free()
		return false
	
	instantiated_ally.queue_free()
	return true

func place_ally_in_cell(cell:Cell, ally:PackedScene):
	var adjacent_cell : Cell = _get_right_adjacent_cell(cell)
	var instantiated_ally : Ally  = ally.instantiate() as Ally
	
	cell.add_child(instantiated_ally)
	instantiated_ally.assigned_cell = cell
	
	cell.is_occupied = true
	
	if instantiated_ally.occupies_two_cells:
		adjacent_cell.is_occupied = true
		instantiated_ally.cell_occupant_item_destroyed.connect(_on_ally_item_destroyed)
	
	instantiated_ally.ally_died.connect(_on_placed_ally_ally_died)

	_set_ally_collision_and_visibility_settings(instantiated_ally, cell.name)
	instantiated_ally.global_position = cell.global_position + (cell.size/2)
	if instantiated_ally is MoneyProvider:
		instantiated_ally.connect("coin_picked_up", _on_coin_picked_up.bind(instantiated_ally.coin_value))
	instantiated_ally.adjust_location_in_cell() # Doesn't work from _ready()

func place_falling_ally_in_cell(cell:Cell, ally:PackedScene):
	var instantiated_ally : Ally  = ally.instantiate() as Ally
	instantiated_ally.assigned_cell = cell
	cell.is_occupied = true
	
	instantiated_ally.ally_died.connect(_on_placed_ally_ally_died)
	_set_falling_ally_collision_and_visibility_settings(instantiated_ally, cell.name)
	ally_for_cell_requested.emit(instantiated_ally, cell)

func place_special_ally_in_cell(cell:Cell, ally:PackedScene):
	var instantiated_ally : Ally  = ally.instantiate() as Ally
	
	cell.add_child(instantiated_ally)
	_set_special_ally_collision_and_visibility_settings(instantiated_ally, cell.name)

func remove_ally_from_cell(cell:Cell):
	for child in cell.get_children():
		if child is Ally:
			child.auto_destroy() 

func _enable_cell_occupancy(cell:Cell):
	cell.is_occupied = false

func _set_special_ally_collision_and_visibility_settings(ally:Ally, cell_name:String):
	if cell_name.begins_with("Row1"):
		
		ally.set_collision_mask_value(2, true)
		ally.set_z_index(1)
		
	elif cell_name.begins_with("Row2"):
		ally.set_collision_mask_value(4, true)
		ally.set_z_index(3)
		
	elif cell_name.begins_with("Row3"):
		ally.set_collision_mask_value(6, true)
		ally.set_z_index(5)
		
	elif cell_name.begins_with("Row4"):
		ally.set_collision_mask_value(8, true)
		ally.set_z_index(7)
		
	elif cell_name.begins_with("Row5"):
		ally.set_collision_mask_value(10, true)
		ally.set_z_index(9)

func _set_falling_ally_collision_and_visibility_settings(ally:Ally, cell_name:String):
	var collision_masks:Array[int] = []
	
	if cell_name.begins_with("Row1"):
		collision_masks = [2,4]
		ally.set_z_index(1)
		
	elif cell_name.begins_with("Row2"):
		collision_masks = [2,4,6]
		ally.set_z_index(3)
		
	elif cell_name.begins_with("Row3"):
		collision_masks = [4,6,8]
		ally.set_z_index(5)
		
	elif cell_name.begins_with("Row4"):
		collision_masks = [6,8,10]
		ally.set_z_index(7)
		
	elif cell_name.begins_with("Row5"):
		collision_masks = [8,10]
		ally.set_z_index(9)
	
	ally.set_explosion_blast_collision_masks(collision_masks)

func _set_ally_collision_and_visibility_settings(ally:Ally, cell_name:String):
	if cell_name.begins_with("Row1"):
		ally.set_collision_layer_value(1, true)
		
		if ally is ShooterAlly:
			ally.set_z_index(1)
			ally.set_collision_mask_value(2, true)
			ally.set_shooting_range(2)
			ally.set_ally_items_collision_settings(1, 2)
		
		elif ally is MineAlly:
			ally.set_z_index(0)
			ally.set_shooting_range(2)
		
		else:
			ally.set_z_index(1)
		
	elif cell_name.begins_with("Row2"):
		ally.set_collision_layer_value(3, true)
		
		if ally is ShooterAlly:
			ally.set_z_index(3)
			ally.set_collision_mask_value(4, true)
			ally.set_shooting_range(4)
			ally.set_ally_items_collision_settings(3, 4)
			
		elif ally is MineAlly:
			ally.set_z_index(2)
			ally.set_shooting_range(4)
		
		else:
			ally.set_z_index(3)
		
	elif cell_name.begins_with("Row3"):
		ally.set_collision_layer_value(5, true)
		
		if ally is ShooterAlly:
			ally.set_z_index(5)
			ally.set_collision_mask_value(6, true)
			ally.set_shooting_range(6)
			ally.set_ally_items_collision_settings(5, 6)
			
		elif ally is MineAlly:
			ally.set_z_index(4)
			ally.set_shooting_range(6)
		
		else:
			ally.set_z_index(5)
		
	elif cell_name.begins_with("Row4"):
		ally.set_collision_layer_value(7, true)
		
		if ally is ShooterAlly:
			ally.set_z_index(7)
			ally.set_collision_mask_value(8, true)
			ally.set_shooting_range(8)
			ally.set_ally_items_collision_settings(7, 8)
			
		elif ally is MineAlly:
			ally.set_z_index(6)
			ally.set_shooting_range(8)
		
		else:
			ally.set_z_index(7)
		
	elif cell_name.begins_with("Row5"):
		ally.set_collision_layer_value(9, true)
		
		if ally is ShooterAlly:
			ally.set_z_index(9)
			ally.set_collision_mask_value(10, true)
			ally.set_shooting_range(10)
			ally.set_ally_items_collision_settings(9, 10)
			
		elif ally is MineAlly:
			ally.set_z_index(8)
			ally.set_shooting_range(10)
		
		else:
			ally.set_z_index(9)

func _get_coin_drop_wait_time() -> int:
	var random_number_generator := RandomNumberGenerator.new()
	
	var random_int =  random_number_generator.randi_range(coin_dropping_rate.minimum_value, coin_dropping_rate.maximum_value)
	return random_int

func _get_random_cell() -> Cell:
	var random_number_generator := RandomNumberGenerator.new()
	var random_cell_index : int =  random_number_generator.randi_range(0, _coin_landing_cells.size() - 1)
	var random_cell : Cell = _coin_landing_cells[random_cell_index]
	
	return random_cell

func _get_right_adjacent_cell(cell:Cell) -> Cell:
	var adjacent_cell_index : int = cell.get_index() + 1
	var adjacent_cell : Cell
	
	if adjacent_cell_index != 9 and adjacent_cell_index != 18 and adjacent_cell_index != 27 and adjacent_cell_index != 36 and adjacent_cell_index != 45:
		adjacent_cell = self.get_child(adjacent_cell_index)
	
	return adjacent_cell

func _on_ally_item_destroyed(item_owner_cell:Cell):
	var adjacent_cell : Cell = _get_right_adjacent_cell(item_owner_cell)
	_enable_cell_occupancy(adjacent_cell)

func _on_placed_ally_ally_died(ally:Ally, cell:Cell):
	if ally.occupies_two_cells:
		var adjacent_cell : Cell = _get_right_adjacent_cell(cell)
	
		if adjacent_cell != null:
			_enable_cell_occupancy(adjacent_cell)
		
	_enable_cell_occupancy(cell)

func _on_coin_drop_timer_time_up():
	var falling_coin : RubleCoin = load(_COIN_SCENE_PATH).instantiate() as RubleCoin
	var landing_cell : Cell = _get_random_cell()
	
	coin_for_cell_requested.emit(falling_coin, landing_cell)
	
	$CoinDropTimer.wait_time = _get_coin_drop_wait_time()
	$CoinDropTimer.start()
	

func _on_coin_picked_up(coin_value : int):
	coin_picked_up.emit(coin_value)

func _on_cell_pressed(cell: Cell):
	cell_pressed.emit(cell)
