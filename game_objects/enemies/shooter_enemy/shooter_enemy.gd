class_name ShooterEnemy extends Enemy

@export var starting_bullet_position : Vector2
@export var has_special_technique_available : bool
@export var is_walking_shooter : bool
@export var fired_bullets_per_shot : int = 1
@export var wait_time_between_fired_bullets : float

var _current_fired_bullets_wait_time : float
var _opponent_at_shoot_reach : Object
var _current_animation_name : String
var _is_shooting : bool
var _is_waiting_to_shoot : bool
var _already_shot : bool
var _shooting_timer_timeup : bool
var _previous_animation_position : float
var _performed_long_attack_on_last_round : bool
var _performed_close_attack_on_last_round : bool

var _is_performing_blade_strike : bool
var _is_waiting_to_blade_strike : bool
var _already_blade_striked : bool


func _ready():
	if is_in_preview:
#		_adjust_location_in_cell()
		return

	_set_current_hp()
	_connect_timers()
	_update_wait_time_between_fired_bullets()

func _physics_process(_delta):
	if is_in_preview: 
		set_physics_process(false)
		return
	
	if is_dying:
		set_physics_process(false)
		return
	
	_current_animation_name = $AnimationPlayer.current_animation
	
	if _current_animation_name == "_call_eagle": return 
	
	if _current_animation_name == "_land_on_ground":
		_fly_left()
		return
	
	_opponent_at_shoot_reach = $ShootingRange.get_collider() as Object
	
	_check_for_opponent_at_physical_contact()
	
	if _shooting_timer_timeup and (_opponent_at_shoot_reach != null or _opponent_at_physical_contact != null):
		if _opponent_at_physical_contact:
			if (_opponent_at_physical_contact is Ally or _opponent_at_physical_contact is GameCharacterItem) and not _opponent_at_physical_contact is MineAlly and has_physical_contact_weapon and not _performed_close_attack_on_last_round:
				if self is EagleGerman and has_special_technique_available:
					_use_special_technique()
					has_special_technique_available = false
					_shooting_timer_timeup = false
					_decrease_speed()
					return
				
				_is_performing_blade_strike = true
				_is_waiting_to_blade_strike = true
#			else:
#				printt("Waiting to stab", "opponent at physical contact: ", _opponent_at_physical_contact)

		else:
			if not _performed_long_attack_on_last_round:
				_is_shooting = true
#				_is_waiting_to_shoot = true
			else:
				is_moving = true
#		if not _performed_long_attack_on_last_round:
		_shooting_timer_timeup = false
			
	
	if _current_animation_name == "_idle" and _performed_close_attack_on_last_round:
		if _previous_animation_position > $AnimationPlayer.current_animation_position:
			_performed_close_attack_on_last_round = false
			_shooting_timer_timeup = true
			_previous_animation_position = 0
			return
		
		_previous_animation_position = $AnimationPlayer.current_animation_position
		return
	
	if is_moving:
		if is_walking_shooter:
			if not _current_animation_name == "_shoot":
				_play_walking_animation()
		else:
			_play_walking_animation()
		_move_left()
#		_performed_long_attack_on_last_round = false

	if _opponent_at_shoot_reach != null and _current_animation_name == "_walking":
		if (_opponent_at_physical_contact is Ally or _opponent_at_physical_contact is GameCharacterItem) and has_physical_contact_weapon: # and not _performed_long_attack_on_last_round:
			
			if self is EagleGerman and has_special_technique_available:
				_use_special_technique()
				has_special_technique_available = false
				_decrease_speed()
				return
			
			_is_performing_blade_strike = true
			_is_shooting = false
		else:	
			_is_shooting = true


	if _current_animation_name == "_walking" and _opponent_at_shoot_reach != null and _opponent_at_physical_contact == null and _performed_long_attack_on_last_round:
		if _previous_animation_position > $AnimationPlayer.current_animation_position:
			_performed_long_attack_on_last_round = false
			_previous_animation_position = 0
			return
			
		_previous_animation_position = $AnimationPlayer.current_animation_position
	
	if _is_shooting and _current_animation_name == "_walking" and _opponent_at_shoot_reach != null and _opponent_at_physical_contact == null and not _performed_long_attack_on_last_round:
		if _previous_animation_position > $AnimationPlayer.current_animation_position:
			if is_walking_shooter:
				_play_shooting_animation()
#				_performed_long_attack_on_last_round = true
			else:
				is_moving = false
				_play_idle_animation()
				_is_waiting_to_shoot = true
			
				
			_previous_animation_position = 0
			return
			
		_previous_animation_position = $AnimationPlayer.current_animation_position

	if _is_performing_blade_strike and _current_animation_name == "_walking" and _opponent_at_physical_contact != null:
		if _previous_animation_position > $AnimationPlayer.current_animation_position:
			is_moving = false
			_play_idle_animation()
			_is_waiting_to_blade_strike = true
			_previous_animation_position = 0
			return
			
		_previous_animation_position = $AnimationPlayer.current_animation_position
		
	if _is_performing_blade_strike and _current_animation_name == "_shoot" and _opponent_at_physical_contact != null:
		if _previous_animation_position > $AnimationPlayer.current_animation_position:
			is_moving = false
			_play_idle_animation()
			_is_waiting_to_blade_strike = true
			_previous_animation_position = 0
			return
			
		_previous_animation_position = $AnimationPlayer.current_animation_position
		
	if _is_shooting and _current_animation_name == "_idle" and _is_waiting_to_shoot:
		if _previous_animation_position > $AnimationPlayer.current_animation_position:
			_is_waiting_to_shoot = false
			_previous_animation_position = 0
			return
		_previous_animation_position = $AnimationPlayer.current_animation_position
		

	if _is_performing_blade_strike and _current_animation_name == "_idle" and _is_waiting_to_blade_strike:
		if _previous_animation_position > $AnimationPlayer.current_animation_position:
			_is_waiting_to_blade_strike = false
			_previous_animation_position = 0
			return
		_previous_animation_position = $AnimationPlayer.current_animation_position
		
	if _current_animation_name == "_idle" and _is_shooting and not _already_shot and not _is_waiting_to_shoot:
		_play_shooting_animation()
		_already_shot = true
		$SFXPlayer.play_sound()
		_start_bullet_movement_animation()

	if _current_animation_name == "_idle" and _is_shooting and _already_shot and not _is_waiting_to_shoot:
		if _opponent_at_physical_contact == null:
			if _opponent_at_shoot_reach != null:
#				printt("Is Waiting to shoot")
				_is_waiting_to_shoot = true
			else:
				is_moving = true
		else:
			if _opponent_at_shoot_reach != null:
#				printt("Is Waiting to shoot")
				_is_waiting_to_shoot = true
			else:
#				printt("Is Moving")
				is_moving = true
			return

	if _current_animation_name == "_shoot" and is_walking_shooter and not _already_shot and not _is_waiting_to_shoot:
		if _previous_animation_position > $AnimationPlayer.current_animation_position:
			_play_walking_animation() 
			
			if _opponent_at_physical_contact:
				_on_close_attack_performed()
			else:
				_on_long_shot_fired()
#					is_moving = true

			_is_shooting = false
			_already_shot = true
#			_is_waiting_to_shoot = false

			_previous_animation_position = 0
			return
		else:
			if _opponent_at_shoot_reach == null:
				is_moving = true

		_previous_animation_position = $AnimationPlayer.current_animation_position
		
	if _current_animation_name == "_shoot" and _is_shooting and is_walking_shooter and not _performed_long_attack_on_last_round:
		_performed_long_attack_on_last_round = true
		for ii in fired_bullets_per_shot:
			$SFXPlayer.play_sound()
			_start_bullet_movement_animation()
			await get_tree().create_timer(_current_fired_bullets_wait_time).timeout
		
		_already_shot = false
#		_is_waiting_to_shoot = false


	if _current_animation_name == "_idle" and _is_performing_blade_strike and not _already_blade_striked and not _is_waiting_to_blade_strike:
		_play_blade_strike_animation()
		_already_blade_striked = true
		$StabSFXPlayer.play_sound()
		if _opponent_at_physical_contact != null:
			_opponent_at_physical_contact.receive_damage(damage_per_hit, "close_normal")


	if _current_animation_name == "_shoot" and not is_walking_shooter:
		if _previous_animation_position > $AnimationPlayer.current_animation_position:
			if _opponent_at_shoot_reach != null:
				_play_idle_animation() # Abrupt Texture Change
				
				if _opponent_at_physical_contact:
					_on_close_attack_performed()
				else:
					_on_long_shot_fired()
#					is_moving = true

			_is_shooting = false
			_already_shot = false

			_previous_animation_position = 0
			return
		else:
			if _opponent_at_shoot_reach == null:
				is_moving = true

		_previous_animation_position = $AnimationPlayer.current_animation_position

	if _current_animation_name == "_shoot" and is_walking_shooter:
		if _previous_animation_position > $AnimationPlayer.current_animation_position:
			if _opponent_at_shoot_reach != null:
				_play_walking_animation() # Abrupt Texture Change
				
				if _opponent_at_physical_contact:
					_on_close_attack_performed()
				else:
					_on_long_shot_fired()
#					is_moving = true

			_is_shooting = false
			_already_shot = false

			_previous_animation_position = 0
			return
		else:
			if _opponent_at_shoot_reach == null:
				is_moving = true

		_previous_animation_position = $AnimationPlayer.current_animation_position

	if _current_animation_name == "_stab":
		if _previous_animation_position > $AnimationPlayer.current_animation_position:
			if _opponent_at_physical_contact != null:
				_play_idle_animation() # Abrupt Texture Change
#				is_moving = false
			
			_on_close_attack_performed()
			_is_performing_blade_strike = false
			_already_blade_striked = false

			_previous_animation_position = 0
			return
		else:
			if _opponent_at_physical_contact == null and _opponent_at_shoot_reach == null:
#				printt("bug", _performed_close_attack_on_last_round)
				_play_idle_animation()
				is_moving = true
				_is_performing_blade_strike = false
				_already_blade_striked = false
				_on_close_attack_performed()
				_previous_animation_position = 0
				return
			elif _opponent_at_physical_contact == null and _opponent_at_shoot_reach != null:
#				printt("prevented bug")
				_play_idle_animation()
				_is_shooting = true
				_is_performing_blade_strike = false
				_already_blade_striked = false
				_on_close_attack_performed()
				_previous_animation_position = 0
				return

		_previous_animation_position = $AnimationPlayer.current_animation_position

	if _current_animation_name == "_idle" and not _is_waiting_to_shoot and not _is_waiting_to_blade_strike:
		if _previous_animation_position > $AnimationPlayer.current_animation_position:
			if _opponent_at_shoot_reach == null and _opponent_at_physical_contact == null:
				is_moving = true
				_shooting_timer_timeup = false

			_previous_animation_position = 0
			return

		_previous_animation_position = $AnimationPlayer.current_animation_position

	if _current_animation_name == "_idle" and _is_waiting_to_shoot and _shooting_timer_timeup: # and _performed_long_attack_on_last_round:
		_is_waiting_to_shoot = false
		is_moving = true
#		printt("prevented bug") 
		return
		
	if _current_animation_name == "_idle" and _is_waiting_to_shoot and _already_shot and _is_shooting: # and _performed_long_attack_on_last_round:
		_already_shot = false 
		return
	
	
func _update_wait_time_between_fired_bullets():
	match speed:
		"very_slow":
			_current_fired_bullets_wait_time = wait_time_between_fired_bullets * 2
		"slow":
			_current_fired_bullets_wait_time = wait_time_between_fired_bullets
		"medium":
			_current_fired_bullets_wait_time = wait_time_between_fired_bullets / 1.5
		"fast":
			_current_fired_bullets_wait_time = wait_time_between_fired_bullets / 2
			
func set_shooting_range(enemy_collision_mask:int):
	if not self is ShooterEnemy: return
	
	var shooting_range : RayCast2D = $ShootingRange as RayCast2D
	shooting_range.set_collision_mask_value(enemy_collision_mask, true)


func _check_for_opponent_at_physical_contact():
	var last_movement_collider : KinematicCollision2D = self.move_and_collide(Vector2(-0.8,0), true) # Test Only Must be true
	if last_movement_collider != null:
		_opponent_at_physical_contact = last_movement_collider.get_collider()
	else:
		_opponent_at_physical_contact = null

func _move_left():
	#self.position.x -= 0.5866666666666667 # 35.2 / 60
	var base_enemy_movement : float = 0.8 # Pixels for 1/60 of a second
	
	match speed:
		"very_slow":
			$AnimationPlayer.speed_scale = 0.5
			self.position.x -= base_enemy_movement * 0.5
		"slow":
			$AnimationPlayer.speed_scale = 1
			self.position.x -= base_enemy_movement
		"medium":
			$AnimationPlayer.speed_scale = 1.5
			self.position.x -= base_enemy_movement * 1.5
		"fast":
			$AnimationPlayer.speed_scale = 2
			self.position.x -= base_enemy_movement * 2
	_check_for_opponent_at_physical_contact()

func _play_idle_animation():
	$AnimationPlayer.play("_idle")

func _play_walking_animation():
	$AnimationPlayer.play("_walking")

func _play_death_animation():
	$AnimationPlayer.play("_death")

func _play_shooting_animation():
	$AnimationPlayer.play("_shoot")

func _play_blade_strike_animation():
	$AnimationPlayer.play("_stab")

func _connect_timers():
	$ShootingTimer.timeout.connect(_on_shooting_timer_timeout)

func _start_bullet_movement_animation():
	var gun_bullet_scene : PackedScene = load("res://game_objects/components/bullet/gun_bullet/gun_bullet.tscn")
	var gun_bullet : GunBullet = gun_bullet_scene.instantiate() as GunBullet
	self.add_child(gun_bullet)
	gun_bullet.position = Vector2(starting_bullet_position)

	gun_bullet.bullet_sender = self
	gun_bullet.start_movement_process()

func _on_long_shot_fired():
	_performed_long_attack_on_last_round = true
	$ShootingTimer.start()

func _on_close_attack_performed():
	_performed_close_attack_on_last_round = true
	$ShootingTimer.start()

func _on_shooting_timer_timeout():
	_shooting_timer_timeup = true

func _use_special_technique():
	pass

func _fly_left():
	pass
