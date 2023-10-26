class_name SpecialAlly extends Ally

var _is_running_right : bool

func _process(_delta):
	if _is_running_right:
		_move_right()
		
		if _opponent_at_physical_contact != null:
			_on_bear_touched_opponent()
		
		if self.position.x > 2000:
			printt("queue free")
			self.queue_free()

func _move_right():
	#self.position.x -= 0.5866666666666667 # 35.2 / 60
	var base_enemy_movement : float = 0.8 # Pixels for 1/60 of a second
	
	match speed:
		"very_slow":
			$AnimationPlayer.speed_scale = 0.5
			self.position.x += base_enemy_movement * 0.5
		"slow":
			$AnimationPlayer.speed_scale = 1
			self.position.x += base_enemy_movement
		"medium":
			$AnimationPlayer.speed_scale = 1.5
			self.position.x += base_enemy_movement * 1.5
		"fast":
			$AnimationPlayer.speed_scale = 2
			self.position.x += base_enemy_movement * 2
	_check_for_opponent_at_physical_contact()

func _on_bear_touched_opponent():
	_opponent_at_physical_contact.auto_destroy()
	_opponent_at_physical_contact = null
