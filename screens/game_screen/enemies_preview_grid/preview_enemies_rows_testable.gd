class_name PreviewEnemiesRowsTestable extends Control

@export var all_level_enemies: Array[EnemyWave] = [] : set = _set_all_level_enemies
@export var total_enemies_to_display : int
var _sorted_enemy_scenes : Array[PackedScene]

var _all_enemy_scenes_to_display : Array[PackedScene]
var _total_enemies_count : float = 0.0
var _enemy_kinds_count : Dictionary
var _all_level_enemy_kinds : Array[String]
var _all_level_enemy_scenes : Array[Array] #Array[Array[PackedScene]]


func _ready():
	_make_initial_calculations()
	_get_sorted_enemy_scenes()
	_populate_enemy_rows()

func _get_next_row(enemies_row:EnemiesRow) -> EnemiesRow:
	var returned_enemies_row : EnemiesRow
	
	for child_enemies_row in self.get_children() as Array[EnemiesRow]:
		if child_enemies_row.row_number == enemies_row.row_number + 1:
			returned_enemies_row = child_enemies_row
	
	return returned_enemies_row

func _get_previous_row(enemies_row:EnemiesRow) -> EnemiesRow:
	var returned_enemies_row : EnemiesRow
	
	for child_enemies_row in self.get_children() as Array[EnemiesRow]:
		if child_enemies_row.row_number == enemies_row.row_number - 1:
			returned_enemies_row = child_enemies_row
	
	return returned_enemies_row

func _set_all_level_enemies(new_value:Array[EnemyWave]):
	all_level_enemies = new_value

func _make_initial_calculations():
	for ii in all_level_enemies.size():
		var wave : EnemyWave = all_level_enemies[ii]
		var all_wave_enemy_groups : Array[EnemyQuantity] = []
		
		for jj in wave.enemies.size():
			all_wave_enemy_groups.append(wave.enemies[jj])
		
		for enemy_group in all_wave_enemy_groups:
			var enemy_kind : String = enemy_group.enemy
			var enemy_quantity : float = float(enemy_group.quantity) 
			
			if _enemy_kinds_count.has(enemy_kind):
				_enemy_kinds_count[enemy_kind] += enemy_quantity
			else:
				_enemy_kinds_count[enemy_kind] = enemy_quantity
			
			if not _all_level_enemy_kinds.has(enemy_kind):
				_all_level_enemy_kinds.append(enemy_kind)
				
			_total_enemies_count += enemy_quantity
	
	for ii in _all_level_enemy_kinds.size():
		var enemy_kind : String = _all_level_enemy_kinds[ii]
		_all_level_enemy_scenes.append([])
		var total_enemies_of_kind : int = _enemy_kinds_count[enemy_kind]
		
		for jj in total_enemies_of_kind:
			var enemy_scene : PackedScene = GlobalConstants.enemy_scenes_list[enemy_kind]
			_all_level_enemy_scenes[ii].append(enemy_scene)

	_all_level_enemy_scenes.sort_custom(_sort_descending)
	
	for ii in _all_level_enemy_scenes.size():
		var enemy_scenes_group : Array = _all_level_enemy_scenes[ii]
		var scenes_group_proportion_to_total : float = enemy_scenes_group.size() / _total_enemies_count
		var enemies_to_display : int = int(total_enemies_to_display * scenes_group_proportion_to_total)
#		printt(scenes_group_proportion_to_total)
#		printt(enemies_to_display)
		if enemies_to_display <= 1:
			_all_enemy_scenes_to_display.append(enemy_scenes_group[0])
			enemy_scenes_group.pop_front()
		else:
			for jj in enemies_to_display:
				_all_enemy_scenes_to_display.append(enemy_scenes_group[0])
				enemy_scenes_group.pop_front()
		
	if _all_enemy_scenes_to_display.size() < total_enemies_to_display:
		var enemies_rest : int = total_enemies_to_display - _all_enemy_scenes_to_display.size()
		
		for ii in enemies_rest:
			var extra_enemy_scene : PackedScene = _all_level_enemy_scenes[ii][0]
			
			_all_enemy_scenes_to_display.append(extra_enemy_scene)
			_all_level_enemy_scenes[ii].pop_front()
	elif _all_enemy_scenes_to_display.size() > total_enemies_to_display:
		printt("enemies preview overload", total_enemies_to_display ,_all_enemy_scenes_to_display.size())
	
	_all_level_enemy_scenes.clear()


func _sort_descending(a, b):
	if a.size() > b.size():
		return true
	return false

func _get_sorted_enemy_scenes():
	while  _all_enemy_scenes_to_display.size() != 1:
		var random_index = _get_random_index( _all_enemy_scenes_to_display.size() - 1)
		_sorted_enemy_scenes.append( _all_enemy_scenes_to_display[random_index])
		_all_enemy_scenes_to_display.erase(_all_enemy_scenes_to_display[random_index])
	_sorted_enemy_scenes.append(_all_enemy_scenes_to_display[0])
	_all_enemy_scenes_to_display.erase(_all_enemy_scenes_to_display[0])

func _get_random_index(max_value:int) -> int:
	var random_number_generator := RandomNumberGenerator.new()
	
	var random_int : int =  random_number_generator.randi_range(0,max_value)
	
	return random_int

func _populate_enemy_rows():
	var total_enemies_added_to_rows : int = 0
	
	while total_enemies_added_to_rows != total_enemies_to_display:
		var child_random_index : int = _get_random_index(self.get_child_count() - 1)
		var random_enemies_row : EnemiesRow = self.get_child(child_random_index)
		
		if not random_enemies_row.one_column_occupied and not random_enemies_row.two_columns_occupied:
			if random_enemies_row.row_number == 1:
				var next_enemies_row : EnemiesRow = _get_next_row(random_enemies_row)
				
				if not next_enemies_row.two_columns_occupied:
					var random_int_of_three : int = _get_random_index(2)
					
					if random_int_of_three == 2:
						if _sorted_enemy_scenes.size() >= 2:
							_add_two_enemies_to_row(random_enemies_row)
							total_enemies_added_to_rows += 2
					elif random_int_of_three == 1:
						_add_one_enemy_to_row(random_enemies_row)
						total_enemies_added_to_rows += 1
				else:
						var random_int_of_two : int = _get_random_index(1)
						
						if random_int_of_two == 1:
							_add_one_enemy_to_row(random_enemies_row)
							total_enemies_added_to_rows += 1
			elif random_enemies_row.row_number == 9:
				var last_enemies_row : EnemiesRow = _get_previous_row(random_enemies_row)
				
				if not last_enemies_row.two_columns_occupied:
					var random_int_of_three : int = _get_random_index(2)
					
					if random_int_of_three == 2:
						if _sorted_enemy_scenes.size() >= 2:
							_add_two_enemies_to_row(random_enemies_row)
							total_enemies_added_to_rows += 2
					elif random_int_of_three == 1:
						_add_one_enemy_to_row(random_enemies_row)
						total_enemies_added_to_rows += 1
				else:
					var random_int_of_two : int = _get_random_index(1)
					
					if random_int_of_two == 1:
						_add_one_enemy_to_row(random_enemies_row)
						total_enemies_added_to_rows += 1
			else:
				var next_enemies_row : EnemiesRow = _get_next_row(random_enemies_row)
				var last_enemies_row : EnemiesRow = _get_previous_row(random_enemies_row)

				if next_enemies_row.two_columns_occupied or last_enemies_row.two_columns_occupied:
					var random_int_of_two : int = _get_random_index(1)
					
					if random_int_of_two == 1:
						_add_one_enemy_to_row(random_enemies_row)
						total_enemies_added_to_rows += 1
				else:
					var random_int_of_three : int = _get_random_index(2)
					
					if random_int_of_three == 2:
						if _sorted_enemy_scenes.size() >= 2:
							_add_two_enemies_to_row(random_enemies_row)
							total_enemies_added_to_rows += 2
					elif random_int_of_three == 1:
						_add_one_enemy_to_row(random_enemies_row)
						total_enemies_added_to_rows += 1

func _add_two_enemies_to_row(random_enemies_row:EnemiesRow):
	var enemies_for_row : Array[PackedScene] = []
	
	enemies_for_row.append(_sorted_enemy_scenes[0])
	_sorted_enemy_scenes.pop_front()
	enemies_for_row.append(_sorted_enemy_scenes[0])
	_sorted_enemy_scenes.pop_front()

	random_enemies_row.add_two_enemies_to_row(enemies_for_row)
	random_enemies_row.two_columns_occupied = true

func _add_one_enemy_to_row(random_enemies_row:EnemiesRow):
	random_enemies_row.add_one_enemy_to_row(_sorted_enemy_scenes[0])
	_sorted_enemy_scenes.pop_front()
	
	random_enemies_row.one_column_occupied = true

