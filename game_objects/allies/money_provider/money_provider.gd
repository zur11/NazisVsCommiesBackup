class_name MoneyProvider extends Ally

signal coin_picked_up

@export var coin_value : int
@export var coin_dropping_rate : MinMaxIntRate

@onready var _timer : Timer = $Timer 
@warning_ignore("unused_private_class_variable")
@onready var _animation_player = $AnimationPlayer


func _ready():
	_set_current_hp()
	_start_coin_dropping_process()

#func _set_current_hp():
#	_current_hp = starting_hp

func _start_coin_dropping_process():
	@warning_ignore("integer_division")
	var starting_wait_time : float = _get_coin_drop_wait_time() / 2
	
	_timer.wait_time = starting_wait_time
	_timer.start()
	
func _get_coin_drop_wait_time() -> int:
	var random_number_generator := RandomNumberGenerator.new()
	
	var random_int =  random_number_generator.randi_range(coin_dropping_rate.minimum_value, coin_dropping_rate.maximum_value)
	return random_int
