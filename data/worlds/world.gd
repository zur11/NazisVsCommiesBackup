@tool
class_name World extends Resource

#@export var world_cleared : bool 
@export var world_name : String 
@export var games_menu_background : Texture
@export var normal_button_texture : Texture
@export var selected_button_texture : Texture
@export var levels : Array[Level]
@export var selected_level : Level 
@export var coin_dropping_rate : MinMaxIntRate : set = _set_falling_coin_droping_rate 
@export var falling_coin_value : int : set = _set_falling_coin_value
@export var total_rows_number : int

func _set_falling_coin_droping_rate(new_value:MinMaxIntRate):
	coin_dropping_rate = new_value
#	if coin_dropping_rate == []: return

	for level in levels:
		level.coin_dropping_rate = coin_dropping_rate

func _set_falling_coin_value(new_value:int):
	falling_coin_value = new_value
	if falling_coin_value == 0: return
	
	for level in levels:
		level.falling_coin_value = falling_coin_value

