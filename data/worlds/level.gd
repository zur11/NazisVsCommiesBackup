@tool
class_name Level extends Resource

@export var is_tutorial : bool
@export var level_unlocked : bool
@export var game_background : Texture
@export var game_foreground : Texture
@export var level_name : String : set = _set_level_name
@export var level_thumbnail : Texture 
@export var enemy_thumbnail : Texture
@export var level_allies : Array[PackedScene]
@export var starting_balance : int 
@export var coin_dropping_rate : MinMaxIntRate
@export var falling_coin_value : int
#@export var initial_enemy_spawning_rate : MinMaxIntRate
#@export_enum("easy", "moderate", "hard") var level_difficulty : String
@export_enum("1Row:1", "3Rows:3", "5Rows:5") var playable_rows : int
@export_enum("left", "center", "right") var game_background_position : String
@export var ally_presentation : AllyPresentation
@export var displayed_preview_enemies : int
@export var level_enemies : Array[EnemyWave]
@export var level_coins_reward : int
@export var special_coin_reward : int
@export var background_transitioning_level : bool

func _set_level_name(new_value):
	level_name = new_value

