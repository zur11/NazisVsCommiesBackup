class_name LastColumnEnemyDetectors extends VBoxContainer

signal enemy_reached_last_column(column_number:int)

var playable_rows : int : set = _set_playable_rows
var _enabled_enemy_detectors : Array[Area2D]

func _set_playable_rows(new_value:int):
	playable_rows = new_value
	
	_set_enabled_enemy_detectors()
	_connect_enabled_detectors_signals()
	_set_enabled_detectors_collision_settings()

func _set_enabled_enemy_detectors():
	if playable_rows == 5:
		for enemy_detector in self.get_children():
			if enemy_detector is Area2D:
				_enabled_enemy_detectors.append(enemy_detector)
	
	elif playable_rows == 3:
		for enemy_detector in self.get_children():
			if enemy_detector is Area2D and not enemy_detector.name.ends_with("5") and not enemy_detector.name.ends_with("1"):
				_enabled_enemy_detectors.append(enemy_detector)
	
	elif playable_rows == 1:
		for enemy_detector in self.get_children():
			if enemy_detector is Area2D and enemy_detector.name.ends_with("3"):
				_enabled_enemy_detectors.append(enemy_detector)

func _set_enabled_detectors_collision_settings():
	match playable_rows:
		5:
			for ii in _enabled_enemy_detectors.size():
				var enemy_detector : Area2D = _enabled_enemy_detectors[ii]
				match ii:
					0:
						enemy_detector.set_collision_mask_value(2, true)
					1:
						enemy_detector.set_collision_mask_value(4, true)
					2:
						enemy_detector.set_collision_mask_value(6, true)
					3:
						enemy_detector.set_collision_mask_value(8, true)
					4:
						enemy_detector.set_collision_mask_value(10, true)
		3: 
			for ii in _enabled_enemy_detectors.size():
				var enemy_detector : Area2D = _enabled_enemy_detectors[ii]
				match ii:
					0:
						enemy_detector.set_collision_mask_value(4, true)
					1:
						enemy_detector.set_collision_mask_value(6, true)
					2:
						enemy_detector.set_collision_mask_value(8, true)
		1:
			_enabled_enemy_detectors[0].set_collision_mask_value(6, true)

func _connect_enabled_detectors_signals():
	for enemy_detector in _enabled_enemy_detectors:
		enemy_detector.connect("body_entered", _on_enemy_detector_enemy_detected.bind(int(enemy_detector.name.trim_prefix("RowEnemyDetector"))))
#		enemy_detector.

func _on_enemy_detector_enemy_detected(_body:Node2D, row_number:int):
	enemy_reached_last_column.emit(row_number)
