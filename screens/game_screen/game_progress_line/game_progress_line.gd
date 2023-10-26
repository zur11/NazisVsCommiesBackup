class_name GameProgressLine extends Control

const _FLAG_SCENE_PATH : String = "res://screens/game_screen/game_progress_line/leningrad_flag_1.tscn"

var total_spawning_time : float : set = _set_total_spawning_time
var _progress_line_x_size : float
var _head_movement_per_second : float

@onready var _line_texture_back : TextureRect = $LineTextureBack
@onready var _line_texture_front : TextureRect = $LineTextureFront
@onready var _head_texture : TextureRect = $NaziHeadTexture

func add_flagged_wave(time_position:float):
	var flag : TextureRect = load(_FLAG_SCENE_PATH).instantiate()
	
	
	var flag_positon := Vector2(_progress_line_x_size - (time_position * _head_movement_per_second), -10)
	
	self.add_child(flag)
	flag.position = flag_positon

func make_head_advance(seconds_to_advance:float):
	var tween : Tween = create_tween()
	var tween2 : Tween = create_tween()
	
	tween.tween_property(_head_texture, "position", Vector2(_head_texture.position.x -(_head_movement_per_second * seconds_to_advance), _head_texture.position.y), seconds_to_advance)

	tween2.tween_property(_line_texture_front, "size", Vector2(_line_texture_front.size.x -(_head_movement_per_second * seconds_to_advance), _line_texture_front.size.y), seconds_to_advance)
	
func _set_total_spawning_time(new_value:float):
	total_spawning_time = new_value
	_calculate_initial_variables()
	
func _calculate_initial_variables():
	_head_texture.set_z_index(1)
	_progress_line_x_size = _line_texture_back.size.x - _head_texture.size.x
	_head_movement_per_second = _progress_line_x_size / total_spawning_time


