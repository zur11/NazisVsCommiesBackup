class_name GameStartCountDown extends Control

signal count_down_finished

@export var count_down_audio : AudioStreamMP3
@export var total_count_down_time:float
@export var countdown_numbers : Array[Texture]
@export var starting_prompt : Texture

@onready var _count_down_texture_text : TextureRect = $CountDownTextureText
@onready var _count_down_audio_player : SFXPlayer = $SFXPlayer


func start_count_down():
	var waiting_time_step : float = total_count_down_time / (countdown_numbers.size() + 1)
	
	_count_down_audio_player.stream = count_down_audio
	_count_down_audio_player.play_sound()
	
	for count_down_number in countdown_numbers:
		_count_down_texture_text.texture = count_down_number
		await  get_tree().create_timer(waiting_time_step).timeout
	
	_count_down_texture_text.texture = starting_prompt
	await  get_tree().create_timer(waiting_time_step).timeout
	
	count_down_finished.emit()
