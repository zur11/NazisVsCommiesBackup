class_name ShooterAlly extends Ally

signal cell_occupant_item_destroyed(cell:Cell)


@export_enum("none:0", "low:1", "high:2") var damage_per_hit : int 
@export var has_weapon_reloading : bool
@export var starting_bullet_position : Vector2
@export var fired_bullets_per_shot : int = 1
@export var has_physical_contact_weapon : bool
@export var main_weapon_sound : AudioStreamMP3
@export var ally_bullet_scene : PackedScene

var _opponent_at_shoot_reach : Object

var _current_animation_name : String
var _is_shooting : bool
var _is_waiting_to_shoot : bool
var _already_shot : bool
var _shooting_timer_timeout : bool
var _previous_animation_position : float

var _is_performing_blade_strike : bool
var _is_waiting_to_blade_strike : bool
var _already_blade_striked : bool

var _performed_long_attack_on_last_round : bool
var _performed_close_attack_on_last_round : bool

# For Item Carrier Shooters
@warning_ignore("unused_private_class_variable")
var _items : Array[GameCharacterItem]

func _ready():
	_set_current_hp()
	_connect_shooting_timer()
	_set_initial_items()
	_connect_items_signals()
	_update_animations_speed()

func _physics_process(_delta):
	_current_animation_name = $AnimationPlayer.current_animation
	_opponent_at_shoot_reach = $ShootingRange.get_collider() as Object
	
	_check_for_opponent_at_physical_contact()
	
	if _shooting_timer_timeout and _opponent_at_shoot_reach != null:
		if _opponent_at_physical_contact:
			if _opponent_at_physical_contact is Enemy and has_physical_contact_weapon:
				_is_performing_blade_strike = true
				_is_waiting_to_blade_strike = true
			else:
				_is_shooting = true
				_is_waiting_to_shoot = true
		else:
			_is_shooting = true
			_is_waiting_to_shoot = true
			
		_shooting_timer_timeout = false

	if _current_animation_name == "_idle" and _performed_long_attack_on_last_round:
		if _previous_animation_position > $AnimationPlayer.current_animation_position:
			_performed_long_attack_on_last_round = false
			_shooting_timer_timeout = true
			_previous_animation_position = 0
			return
		
		_previous_animation_position = $AnimationPlayer.current_animation_position
		return

	if _current_animation_name == "_idle" and _performed_close_attack_on_last_round:
		if _previous_animation_position > $AnimationPlayer.current_animation_position:
			_performed_close_attack_on_last_round = false
			_shooting_timer_timeout = true
			_previous_animation_position = 0
			return
		
		_previous_animation_position = $AnimationPlayer.current_animation_position
		return
		
	if _is_shooting and _current_animation_name == "_idle" and _is_waiting_to_shoot and _opponent_at_shoot_reach != null:
		if _previous_animation_position > $AnimationPlayer.current_animation_position:
			_is_waiting_to_shoot = false
			_previous_animation_position = 0
			return
			
		_previous_animation_position = $AnimationPlayer.current_animation_position
		

	if _is_performing_blade_strike and _current_animation_name == "_idle" and _is_waiting_to_blade_strike and _opponent_at_physical_contact != null and not _performed_close_attack_on_last_round:
		if _previous_animation_position > $AnimationPlayer.current_animation_position:
			
			_is_waiting_to_blade_strike = false
			_previous_animation_position = 0
			return
			
		_previous_animation_position = $AnimationPlayer.current_animation_position
	

	if _current_animation_name == "_idle" and _is_shooting and not _already_shot and not _is_waiting_to_shoot:
		$AnimationPlayer.play("_shoot")
		if $SFXPlayer.stream == null:
			$SFXPlayer.stream = main_weapon_sound

		$SFXPlayer.play_sound()
		_already_shot = true
		
		for ii in fired_bullets_per_shot:
			_start_bullet_movement_animation()
			await get_tree().create_timer(0.2).timeout
		
	if _current_animation_name == "_idle" and _is_performing_blade_strike and not _already_blade_striked and _opponent_at_physical_contact == null:
		_is_performing_blade_strike = false
		_is_waiting_to_blade_strike = false

	if _current_animation_name == "_idle" and _is_performing_blade_strike and not _already_blade_striked and not _is_waiting_to_blade_strike:
		$AnimationPlayer.play("_stab")
		_already_blade_striked = true
		$StabSFXPlayer.play_sound()
		

	if _current_animation_name == "_stab":
		if _previous_animation_position > $AnimationPlayer.current_animation_position:
			if _opponent_at_physical_contact != null:
				_opponent_at_physical_contact.receive_damage(damage_per_hit, "close_normal")
			$AnimationPlayer.play("_idle")

			_on_close_attack_performed()

			_is_performing_blade_strike = false
			_already_blade_striked = false

			_previous_animation_position = 0
			return
		else:
			if _opponent_at_physical_contact == null:
				$AnimationPlayer.stop()
				$AnimationPlayer.play("_idle")
				
				_is_performing_blade_strike = false
				_already_blade_striked = false
				
				if _opponent_at_shoot_reach != null:
					printt("is shooting")
					_is_shooting = true
				
				_on_close_attack_performed()
				
				_previous_animation_position = 0
#				printt("Posible Bug")
				return
#				printt("Bug", _opponent_at_shoot_reach)
			
#			if _opponent_at_shoot_reach == null:
#				printt("Opponent shoot reach null")

		_previous_animation_position = $AnimationPlayer.current_animation_position
		
	if _current_animation_name == "_shoot" or _current_animation_name == "_reload":
		if _previous_animation_position > $AnimationPlayer.current_animation_position:
			if has_weapon_reloading and _current_animation_name != "_reload":
				await get_tree().create_timer(0.2).timeout
				$AnimationPlayer.play("_reload")
				$ReloadSFXPlayer.play_sound()
			else:
#				printt("Cambio de _shoot o _reload a _idle")
				$AnimationPlayer.play("_idle")
			
			if _opponent_at_physical_contact:
				_on_close_attack_performed()
			else:
				_on_long_shot_fired()

			_is_shooting = false
			_already_shot = false

			_previous_animation_position = 0
			return
		else:
			if _opponent_at_shoot_reach == null:
				$AnimationPlayer.stop()
				$AnimationPlayer.play("_idle")
				_is_shooting = false
				_already_shot = false
				_shooting_timer_timeout = true
				_previous_animation_position = 0
				return

		_previous_animation_position = $AnimationPlayer.current_animation_position

	if _current_animation_name == "_idle" and _opponent_at_shoot_reach == null and not _performed_long_attack_on_last_round and not _is_shooting and _previous_animation_position != 0:
		_previous_animation_position = 0
		_shooting_timer_timeout = true

func _start_bullet_movement_animation():
	var ally_bullet : Bullet = ally_bullet_scene.instantiate()
	self.add_child(ally_bullet)
	ally_bullet.position = starting_bullet_position

	ally_bullet.bullet_sender = self
	ally_bullet.start_movement_process()

func _set_initial_items():
	pass

func set_shooting_range(ally_collision_mask:int):
	var shooting_range : RayCast2D = $ShootingRange
	shooting_range.set_collision_mask_value(ally_collision_mask, true)

func _on_cell_ocuppant_item_destroyed(_item:GameCharacterItem):
	pass

func _connect_shooting_timer():
	$ShootingTimer.timeout.connect(_on_shooting_timer_timeout)

func _on_shooting_timer_timeout():
	_shooting_timer_timeout = true

func _connect_items_signals():
	pass

func set_ally_items_collision_settings(_ally_collision_layer: int, _ally_collision_mask:int):
	pass

func _on_close_attack_performed():
	_performed_close_attack_on_last_round = true
	$ShootingTimer.start()

func _on_long_shot_fired():
	_performed_long_attack_on_last_round = true
	$ShootingTimer.start()

