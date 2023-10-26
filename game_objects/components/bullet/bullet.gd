class_name Bullet extends CharacterBody2D

var bullet_sender : GameCharacter : set = _set_bullet_sender
var _inflicted_damage_points : int
var _is_moving_right : bool
var _has_been_shot : bool

func _physics_process(_delta):
	if _has_been_shot:
		if _is_moving_right:
			_move_right()
		else:
			_move_left()

func _set_bullet_sender(new_value:GameCharacter):
	bullet_sender = new_value
	_set_bullet_collision_and_visibility_settings()
	_set_inflicted_damage_points()

func start_movement_process():
	if bullet_sender.character_faction == "ally":
		_is_moving_right = true

	elif bullet_sender.character_faction == "enemy":
		$BulletTexture.flip_h = true
		_is_moving_right = false
	
	_has_been_shot = true

func _set_bullet_collision_and_visibility_settings():
	var _game_screen_user_data : GameScreenUserData = UserDataManager.user_data.game_screen_user_data
	
	var total_rows_number : int = 10 # _game_screen_user_data.total_rows_number
#	if playable_rows == 5:
	for ii in total_rows_number * 2:
		if bullet_sender.get_collision_mask_value(ii+1) == true:
			self.set_collision_mask_value(ii+1, true)
	
	for ii in total_rows_number:
		if bullet_sender.get_z_index() == ii:
			self.set_z_index(ii)
	
#	elif playable_rows == 3:
#		for ii in playable_rows * 2:
#			if bullet_sender.get_collision_mask_value(ii+3) == true:
#				self.set_collision_mask_value(ii+3, true)
#
#		for ii in playable_rows:
#			if bullet_sender.get_z_index() == ii+1:
#				self.set_z_index(ii+1)
#
#	elif playable_rows == 1:
#		for ii in playable_rows * 2:
#			if bullet_sender.get_collision_mask_value(ii+5) == true:
#				self.set_collision_mask_value(ii+5, true)
#
#		self.set_z_index(2)

func _set_inflicted_damage_points():
	_inflicted_damage_points = bullet_sender.damage_per_hit

func _move_right():
	var base_bullet_speed : float = 11.73
	self.position.x += base_bullet_speed
	_check_for_bullet_receiver(base_bullet_speed)

func _move_left():
	var base_bullet_speed : float = -11.73
	self.position.x += base_bullet_speed
	_check_for_bullet_receiver(base_bullet_speed)

func _check_for_bullet_receiver(bullet_speed:float):
	var last_movement : KinematicCollision2D = self.move_and_collide(Vector2(bullet_speed,0), true)
	if last_movement != null:
#		printt("last bullet movement right: ", last_movement.get_collider())
		var damage_receiver : Object = last_movement.get_collider()
		if self is CannonBullet:
			damage_receiver.auto_destroy()
		else:
			_inflict_damage_to_game_object(damage_receiver)
		_animate_impact()

func _inflict_damage_to_game_object(damage_receiver:Object):
#	printt("Bullet Damage Receiver: ", damage_receiver)
	if self is IceBullet:
		damage_receiver.receive_damage(_inflicted_damage_points, "long_freezing")
		return
	
	damage_receiver.receive_damage(_inflicted_damage_points, "long_normal")

func _animate_impact():
	if not self is CannonBullet:
		self.queue_free()
		
