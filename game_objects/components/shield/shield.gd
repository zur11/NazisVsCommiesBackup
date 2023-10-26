class_name Shield extends GameCharacterItem

signal item_destroyed(item:GameCharacterItem)

@export_enum("veryLow:10", "low:28", "high:42", "veryHigh:64") var starting_hp : int
var shield_user : GameCharacter : set = _set_shield_user
var _current_hp : int
@onready var _shield_state : AnimatedSprite2D = $ShieldState
var _states_names : Array[String] = ["default", "two_slabs", "one_slab", "no_slabs"]

func _ready():
	_set_shield_state()
	_set_current_hp()

func _set_shield_state():
	_shield_state.animation = _states_names[0]

func _set_current_hp():
	_current_hp = starting_hp

func receive_damage(damage_points:int, _damage_type:String):
	$AnimationPlayer.play("_receive_damage")
	_current_hp -= damage_points
	_check_for_textures_update()
	if _current_hp <= 0:
		_die()

func _check_for_textures_update():
	var planks_number : int = 3
	@warning_ignore("integer_division")
	var plank_hp_duration : float = starting_hp / 4
	
	if _current_hp <= plank_hp_duration * planks_number:
		_shield_state.animation = _states_names[1]

	if _current_hp <= plank_hp_duration * (planks_number - 1):
		_shield_state.animation = _states_names[2]
		
	if _current_hp <= plank_hp_duration * (planks_number - 2):
		_shield_state.animation = _states_names[3]

func _die():
	item_destroyed.emit(self)
	self.queue_free()

func _set_shield_user(new_value:GameCharacter):
	shield_user = new_value
	_set_shield_collision_layer()

func _set_shield_collision_layer():
	var _game_screen_user_data : GameScreenUserData = UserDataManager.user_data.game_screen_user_data
	
	#if _game_screen_user_data.playable_rows != 5 : return # Pending Tutorial Levels
	
	for ii in _game_screen_user_data.total_rows_number * 2:
		if shield_user.get_collision_mask_value(ii+1) == true:
#			printt("Shield collision layer set: ", ii + 1)
			self.set_collision_mask_value(ii+1, true)
			return
