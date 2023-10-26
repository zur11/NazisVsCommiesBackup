class_name RubleCoin extends TextureButton

signal picked_up

var timer_wait_time : float : set = _set_timer_wait_time
@onready var timer : Timer = $Timer

func _set_timer_wait_time(new_value:float):
	timer_wait_time = new_value
	timer.wait_time = timer_wait_time
	_start_timer()

func _start_timer():
	timer.start()

func _on_timer_timeout():
	self.queue_free()

func _on_pressed():
	picked_up.emit()
	self.queue_free()
