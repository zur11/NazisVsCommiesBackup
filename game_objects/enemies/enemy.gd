class_name Enemy extends GameCharacter

signal died

const _UNFREEZED_COLOR := Color(1,1,1)
const _FREEZED_COLOR := Color(0,1,1)

@export var enemy_name : String


@export_enum("veryLow:10", "low:20", "high:30", "veryHigh:40") var starting_hp : int
@export_enum("none:0", "low:1", "high:2") var damage_per_hit : int  
@export_enum("very_slow", "slow", "medium", "fast") var speed : String  
@export var has_physical_contact_weapon : bool
@export var location_in_cell : Vector2

@export var additional_states : int

var _freezing_timer : Timer

var _current_hp : int

var is_in_preview : bool
var is_moving : bool
var _is_freezed : bool : set = _set_is_freezed
var is_dying : bool
@warning_ignore("unused_private_class_variable")
var _opponent_at_physical_contact : Object

@onready var _receive_damage_anim_player : AnimationPlayer = $ReceiveDamage

func _adjust_location_in_cell():
	self.position = location_in_cell

func receive_damage(damage_points:int, damage_type:String):
	if damage_type == "long_freezing" and not _is_freezed:
		_become_freezed()
	
	if damage_type == "explosion":
		_die_by_explosion()
		return
	if damage_type == "bear_bite":
		_die_eaten_by_bear()
		return
		
	$ReceiveDamage.play("_receive_damage_general")

	$ReceiveDamageSFXPlayer.play_sound()
	_current_hp -= damage_points
	
	if _current_hp == starting_hp - 10 and additional_states != 0:
		$StateChangePlayer.play("_state_change_1")
	if _current_hp == starting_hp - 20 and additional_states > 1:
		$StateChangePlayer.play("_state_change_2")
	
	await get_tree().create_timer(0.5).timeout
	if _current_hp <= 0 and not is_dying:
		_die()

func _set_current_hp():
	_current_hp = starting_hp

func _set_is_freezed(new_value:bool):
	_is_freezed = new_value
	
	if _is_freezed:
		_start_freezing_timer()
	else:
		_become_unfreezed()

func _become_freezed():
	_decrease_speed()
	
	self.modulate = _FREEZED_COLOR
	
	_is_freezed = true
	_update_wait_time_between_fired_bullets()

func _become_unfreezed():
	_increase_speed()
	self.modulate = _UNFREEZED_COLOR
	_update_wait_time_between_fired_bullets()

func _start_freezing_timer():
	if not _freezing_timer:
		_freezing_timer = Timer.new()
		_freezing_timer.autostart = false
		_freezing_timer.one_shot = true
		self.add_child(_freezing_timer)
		_freezing_timer.timeout.connect(_on_freezing_timer_timeout)
	
	_freezing_timer.wait_time = 6
	_freezing_timer.start()

func _decrease_speed():
	match self.speed:
		"slow":
			speed = "very_slow"
		"medium":
			speed = "slow"
		"fast":
			speed = "medium"

func _increase_speed():
	match self.speed:
		"very_slow":
			speed = "slow"
		"slow":
			speed = "medium"
		"medium":
			speed = "fast"

func _play_idle_animation():
	pass

func _play_walking_animation():
	pass

func _play_death_animation():
	pass

func _move_left():
	pass

func _check_for_opponent_at_physical_contact():
	pass

func _update_wait_time_between_fired_bullets():
	pass


func auto_destroy(damage_type:String = "normal"):
	if is_dying: return
	
	if damage_type == "normal":
		_die()
	elif damage_type == "explosion":
		_die_by_explosion()

func _die():
	is_dying = true
#	$AnimationPlayer.stop()
#	await get_tree().process_frame
	_play_death_animation()
	$DeathSFXPlayer.play_sound()
	await get_tree().create_timer(1).timeout

	died.emit()
	self.queue_free()

func _die_by_explosion():
	is_dying = true

	$DeathSFXPlayer.play_sound()
	_receive_damage_anim_player.play("_receive_damage_from_explosion")
	await get_tree().create_timer(1).timeout

	died.emit()
	self.queue_free()

func _die_eaten_by_bear():
	is_dying = true

	$DeathSFXPlayer.play_sound()
	_receive_damage_anim_player.play("_receive_damage_eaten")
	await get_tree().create_timer(0.5).timeout
	
	died.emit()
	self.queue_free()
	

func _on_freezing_timer_timeout():
	_is_freezed = false
	

