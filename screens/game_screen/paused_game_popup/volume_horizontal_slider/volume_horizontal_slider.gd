class_name VolumeHorizontalSlider extends HSlider

signal sound_enabling_toggled(sound_enabled:bool)

@export var bus_name : String 


var _sound_is_enabled : bool : set = _set_sound_is_enabled
var bus_index : int

func _ready():
	bus_index = AudioServer.get_bus_index(bus_name)
	self.value_changed.connect(_on_value_changed)
	
	self.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

func _set_sound_is_enabled(new_value:bool):
	_sound_is_enabled = new_value
	
	sound_enabling_toggled.emit(_sound_is_enabled)

func _on_value_changed(value_arg : float):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value_arg))
#	printt(value_arg)
	if self.value > 0.002 and not _sound_is_enabled:
		_sound_is_enabled = true
	elif self.value <= 0.002 and _sound_is_enabled:
		_sound_is_enabled = false
