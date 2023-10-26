class_name RowCannons extends VBoxContainer

signal row_cannon_used(row_cannon_index:int)

var _playable_rows : int
var _enabled_row_cannons : Array[RowCannon]

func initial_setup(playable_rows : int):
	_playable_rows = playable_rows
	
	_connect_row_cannons_signals()
	_set_enabled_row_cannons()

func shoot_in_row(row_number:int):
	for cannon in _enabled_row_cannons:
		if int(cannon.name.trim_prefix("RowCannon")) == row_number:
			cannon.shoot()

func display_all_row_cannons():
	for row_cannon in _enabled_row_cannons:
		row_cannon.is_active = true

func _connect_row_cannons_signals():
	for row_cannon in self.get_children():
		row_cannon.cannon_used.connect(_on_row_cannon_used)

func _set_enabled_row_cannons():
	match _playable_rows:
		5:
			for cannon in self.get_children():
				var row_cannon : RowCannon = cannon as RowCannon
				_enabled_row_cannons.append(row_cannon)
		3:
			for ii in self.get_child_count():
				match ii:
					0:
						self.get_child(ii).visible = false
					1:
						_enabled_row_cannons.append(self.get_child(ii))
					2:
						_enabled_row_cannons.append(self.get_child(ii))
					3:
						_enabled_row_cannons.append(self.get_child(ii))
					4:
						self.get_child(ii).visible = false
		1:
			for ii in self.get_child_count():
				match ii:
					0:
						self.get_child(ii).visible = false
					1:
						self.get_child(ii).visible = false
					2:
						_enabled_row_cannons.append(self.get_child(ii))
					3:
						self.get_child(ii).visible = false
					4:
						self.get_child(ii).visible = false
	
	for enabled_cannon in _enabled_row_cannons:
		enabled_cannon.is_active = true
		
func _on_row_cannon_used(cannon_index:int):
	row_cannon_used.emit(cannon_index)
