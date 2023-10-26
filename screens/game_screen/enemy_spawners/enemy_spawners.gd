class_name EnemySpawners extends VBoxContainer

signal wave_flagged(wave_time_position:float)
signal enemy_spawned(wait_time:float)
signal total_spawning_time_calculated(total_spawning_seconds:float)
signal wave_started(wave_index:int)
signal wave_finished(wave_index:int)
signal enemy_died

var unsorted_enemy_scenes: Array[EnemyWave] : set = _set_unsorted_enemy_scenes
var total_enemies_to_spawn : int
var final_wave_index : int

var _sorted_enemy_scenes : Array[Array] # Array[Array[PackedScene]
var _enemy_spawning_wait_times : Array[Array] # Array[Array[int]
var _playable_rows : int
var _enabled_enemy_spawners : Array[Marker2D]
var _last_used_spawner_index : int
var _wave_just_started : bool 
var _current_wave_index : int

@onready var _enemy_spawning_timer : Timer = $EnemySpawningTimer

func _set_unsorted_enemy_scenes(new_value:Array[EnemyWave]):
	unsorted_enemy_scenes = new_value
	_sort_enemy_scenes()

func _sort_enemy_scenes():
	var total_waves_spawning_time : float = 0.0
	var flagged_wave_time_position : float = 0.0
	
	for ii in unsorted_enemy_scenes.size():
		var wave : EnemyWave = unsorted_enemy_scenes[ii]
		var sorted_wave_enemies : Array[PackedScene] = _get_sorted_wave_enemies(wave.enemies)
		var wave_spawning_rate : Array[int] = [wave.minimum_spawning_rate, wave.maximum_spawning_rate]
		var total_wave_spawning_time : float = 0.0
		final_wave_index = ii
		_enemy_spawning_wait_times.append([])

		if ii == 0:
			for jj in sorted_wave_enemies.size() - 1:
				var enemy_wait_time : float = _get_enemy_spawning_wait_time(wave_spawning_rate)
				_enemy_spawning_wait_times[ii].append(enemy_wait_time)
				total_wave_spawning_time += enemy_wait_time
		else:
			for jj in sorted_wave_enemies.size():
				var enemy_wait_time : float = _get_enemy_spawning_wait_time(wave_spawning_rate)
				_enemy_spawning_wait_times[ii].append(enemy_wait_time)
				total_wave_spawning_time += enemy_wait_time
		
		total_waves_spawning_time += total_wave_spawning_time
		_sorted_enemy_scenes.append(sorted_wave_enemies)
		total_enemies_to_spawn += sorted_wave_enemies.size()
		
#		printt(_enemy_spawning_wait_times)
	
	total_spawning_time_calculated.emit(total_waves_spawning_time)
	
	for ii in _sorted_enemy_scenes.size():
		var wave : EnemyWave = unsorted_enemy_scenes[ii]
		
		if wave.is_flagged:
			wave_flagged.emit(flagged_wave_time_position)
		
		for jj in _enemy_spawning_wait_times[ii].size():
			flagged_wave_time_position += _enemy_spawning_wait_times[ii][jj]



func _get_sorted_wave_enemies(wave_enemies:Array[EnemyQuantity]) -> Array[PackedScene]:
	var enemies_to_sort : Array[PackedScene] = []
	@warning_ignore("unassigned_variable")
	var wave_enemy_scenes : Array[PackedScene]
	
	for ii in wave_enemies.size():
		var wave_enemy : EnemyQuantity = wave_enemies[ii]
		var enemy_quantity : int = wave_enemy.quantity
		for jj in enemy_quantity:
			enemies_to_sort.append(GlobalConstants.enemy_scenes_list[wave_enemy.enemy])
	
	while enemies_to_sort.size() > 1:
		var random_index = _get_random_index(enemies_to_sort.size() - 1)
		wave_enemy_scenes.append(enemies_to_sort[random_index])
		enemies_to_sort.erase(enemies_to_sort[random_index])
	wave_enemy_scenes.append(enemies_to_sort[0])
	enemies_to_sort.erase(enemies_to_sort[0])
	
	return wave_enemy_scenes

func initial_setup(playable_rows : int):
	_playable_rows = playable_rows
	_connect_wave_finished_signal()
	_set_enabled_enemy_spawners()
	_start_enemy_spawning_process()


func _get_enemy_spawning_wait_time(wave_spawning_rates:Array[int]) -> int:
	var random_number_generator := RandomNumberGenerator.new()

	var random_int =  random_number_generator.randi_range(wave_spawning_rates[0], wave_spawning_rates[1])
	return random_int
	
func _connect_wave_finished_signal():
	self.wave_finished.connect(_on_wave_finished)

func _start_enemy_spawning_process():
	_current_wave_index = 0
	var starting_wait_time : float = 15.0
	_enemy_spawning_timer.wait_time = starting_wait_time
	_enemy_spawning_timer.start()
	_wave_just_started = true

func _set_enabled_enemy_spawners():
	if _playable_rows == 5:
		for enemy_spawner in self.get_children():
			if enemy_spawner is Marker2D:
				_enabled_enemy_spawners.append(enemy_spawner)
	
	elif _playable_rows == 3:
		for enemy_spawner in self.get_children():
			if enemy_spawner is Marker2D and not enemy_spawner.name.ends_with("5") and not enemy_spawner.name.ends_with("1"):
				_enabled_enemy_spawners.append(enemy_spawner)
	
	elif _playable_rows == 1:
		for enemy_spawner in self.get_children():
			if enemy_spawner is Marker2D and enemy_spawner.name.ends_with("3"):
				_enabled_enemy_spawners.append(enemy_spawner)


func _set_enemy_collision_and_visibility_settings(enemy:Enemy, spawner_index:int):
	if _playable_rows == 5: 
		match spawner_index:
			0:
				enemy.set_collision_layer_value(2, true)
				enemy.set_collision_mask_value(1, true)
				enemy.set_shooting_range(1)
				enemy.set_z_index(1)
			1:
				enemy.set_collision_layer_value(4, true)
				enemy.set_collision_mask_value(3, true)
				enemy.set_shooting_range(3)
				enemy.set_z_index(3)
			2:
				enemy.set_collision_layer_value(6, true)
				enemy.set_collision_mask_value(5, true)
				enemy.set_shooting_range(5)
				enemy.set_z_index(5)
			3:
				enemy.set_collision_layer_value(8, true)
				enemy.set_collision_mask_value(7, true)
				enemy.set_shooting_range(7)
				enemy.set_z_index(7)
			4:
				enemy.set_collision_layer_value(10, true)
				enemy.set_collision_mask_value(9, true)
				enemy.set_shooting_range(9)
				enemy.set_z_index(9)
				
	elif _playable_rows == 3: 
		match spawner_index:
			0:
				enemy.set_collision_layer_value(4, true)
				enemy.set_collision_mask_value(3, true)
				enemy.set_shooting_range(3)
				enemy.set_z_index(3)
			1:
				enemy.set_collision_layer_value(6, true)
				enemy.set_collision_mask_value(5, true)
				enemy.set_shooting_range(5)
				enemy.set_z_index(5)
			2:
				enemy.set_collision_layer_value(8, true)
				enemy.set_collision_mask_value(7, true)
				enemy.set_shooting_range(7)
				enemy.set_z_index(7)
				
	elif _playable_rows == 1: 
		enemy.set_collision_layer_value(6, true)
		enemy.set_collision_mask_value(5, true)
		enemy.set_shooting_range(5)
		enemy.set_z_index(5)

func _get_random_index(max_value:int) -> int:
	var random_number_generator := RandomNumberGenerator.new()
	
	var random_int : int =  random_number_generator.randi_range(0,max_value)
	
	return random_int
	
func _prepare_next_enemy_to_spawn():
	var current_wave_enemies : Array[PackedScene] = _sorted_enemy_scenes[_current_wave_index]
	var seconds_to_set_in_timer : float
	if _enemy_spawning_wait_times.size() != 0:
		seconds_to_set_in_timer = _enemy_spawning_wait_times[0][0]
	else:
		seconds_to_set_in_timer = 0
		
	_spawn_next_enemy(current_wave_enemies, seconds_to_set_in_timer)
	
	if _enemy_spawning_wait_times.size() != 0:
		if _enemy_spawning_wait_times[0].size() == 1:
			_enemy_spawning_wait_times.pop_front()
		else:
			_enemy_spawning_wait_times[0].pop_front()

func _spawn_next_enemy(current_wave_enemies:Array[PackedScene], seconds_to_set_in_timer:float):
	
	var random_index : int = _get_random_index(_enabled_enemy_spawners.size() - 1)
	
	if not _playable_rows == 1:
		while _last_used_spawner_index == random_index:
			random_index = _get_random_index(_enabled_enemy_spawners.size() - 1)

		_add_enemy_in_selected_spawner(current_wave_enemies[0], random_index)
		enemy_spawned.emit(seconds_to_set_in_timer)
		
		current_wave_enemies.pop_front()
		_last_used_spawner_index = random_index
	
	else: # First Tutorial
		_add_enemy_in_selected_spawner(current_wave_enemies[0], 0)
		enemy_spawned.emit(seconds_to_set_in_timer)
		
		current_wave_enemies.pop_front()
	
	if current_wave_enemies.size() == 0:
		if _current_wave_index != final_wave_index:
			_enemy_spawning_timer.wait_time = seconds_to_set_in_timer
			_enemy_spawning_timer.start()
			
		wave_finished.emit(_current_wave_index)
		return
	
	_enemy_spawning_timer.wait_time = seconds_to_set_in_timer
	_enemy_spawning_timer.start()

func _add_enemy_in_selected_spawner(enemy_scene:PackedScene, spawner_index:int):
	var enemy : Enemy = enemy_scene.instantiate() as Enemy
	_enabled_enemy_spawners[spawner_index].add_child(enemy)
	_set_enemy_collision_and_visibility_settings(enemy, spawner_index)
	enemy.died.connect(_on_enemy_died)
	enemy.is_moving = true

func _on_wave_finished(wave_index:int):
	if wave_index != final_wave_index:
		_current_wave_index += 1
		_wave_just_started = true
#	printt("Wave finished: ", _current_wave_index)

func _on_enemy_spawning_timer_timeout():
	if _wave_just_started:
		wave_started.emit(_current_wave_index)
#		printt("Wave started: ", _current_wave_index)
		_wave_just_started = false
		
	_prepare_next_enemy_to_spawn()
	
func _on_enemy_died():
	enemy_died.emit()

