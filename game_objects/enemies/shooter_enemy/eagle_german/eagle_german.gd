class_name EagleGerman extends ShooterEnemy


func _use_special_technique():
	$AnimationPlayer.play("_call_eagle")
	$AnimationPlayer.queue("_land_on_ground")
	$AnimationPlayer.queue("_walking")
	await get_tree().create_timer(2.2).timeout
	$EagleSFXPlayer.play_sound()
	
func _fly_left():
	var base_fly_movement : float = 1.2 # Pixels for 1/60 of a second
	
	match speed:
		"slow":
			$AnimationPlayer.speed_scale = 1
			self.position.x -= base_fly_movement
		"medium":
			$AnimationPlayer.speed_scale = 1.5
			self.position.x -= base_fly_movement * 1.5
		"fast":
			$AnimationPlayer.speed_scale = 2
			self.position.x -= base_fly_movement * 2
