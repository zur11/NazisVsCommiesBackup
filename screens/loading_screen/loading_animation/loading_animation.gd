extends Node2D

signal loading_animation_ended

var self_index:int
var previous_animation_position : float
var my_packed_string_array:PackedStringArray = []

func _ready():
	$"%AnimationPlayer".speed_scale = 7
	set_process(false)

func _process(_delta):
	if previous_animation_position < $"%AnimationPlayer".current_animation_position and $"%AnimationPlayer".get_queue() == my_packed_string_array:
		var charging_anim = $"%AnimationPlayer".get_animation($"%AnimationPlayer".current_animation) as Animation
		charging_anim.loop_mode = Animation.LOOP_NONE
		$"%AnimationPlayer".queue("_finished_loading")

	previous_animation_position = $"%AnimationPlayer".current_animation_position
	
	if $"%AnimationPlayer".current_animation == "_finished_loading":
		emit_signal("loading_animation_ended")
		set_process(false)

func play_loading_animation(_self_index:int, path_to_load:String):
	self_index = _self_index 

	if $"%AnimationPlayer".current_animation == "_idle":
		$"%AnimationPlayer".play("_loading")
		var charging_anim = $"%AnimationPlayer".get_animation("_loading") as Animation
		charging_anim.loop_mode = Animation.LOOP_PINGPONG

	await AsyncAutoload.load_resource(path_to_load)

	previous_animation_position = $"%AnimationPlayer".current_animation_position
	set_process(true)
	await self.loading_animation_ended
