class_name ObstructerAlly extends Ally

var _total_states : int
var _changing_state_step : float
var _barrier_states_names : Array[String] = ["default", "damaged_1", "damaged_2", "damaged_3"]
@onready var _barrier_texture : AnimatedSprite2D = $BarrierTexture

func _ready():
#	_barrier_texture.set_autoplay(_barrier_states_names[0])
	_set_current_hp()
	_set_changing_state_step()

func _set_changing_state_step():
	_total_states = _barrier_states_names.size()
	
	@warning_ignore("integer_division")
	_changing_state_step = starting_hp / _total_states

func _update_obstructer_texture_state():
	if _is_dying : return 
	
	if _current_hp <= starting_hp - (_changing_state_step * (_total_states - 1)):
		_barrier_texture.animation = _barrier_states_names[3] 
		return
	elif _current_hp <= starting_hp - (_changing_state_step * (_total_states - 2)):
		_barrier_texture.animation = _barrier_states_names[2]
		return 
	elif _current_hp <= starting_hp - (_changing_state_step * (_total_states - 3)):
		_barrier_texture.animation = _barrier_states_names[1] 
