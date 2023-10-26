class_name MainMenu extends Control

signal go_to_sub_menu(sub_menu_name: String)

var _player_user_data : PlayerUserData = UserDataManager.user_data.player_user_data

@onready var _user_stats_container : UserStatsContainer = $UserStatsContainer

func _ready():
	_set_user_stats_container()
	
func _set_user_stats_container():
	_user_stats_container.user_name = _player_user_data.player_name
	_user_stats_container.user_balance = _player_user_data.player_balance


func _on_go_to_games_menu_button_pressed():
	go_to_sub_menu.emit("games_menu")
	$SFXPlayer.play_sound()

func _on_go_to_settings_menu_button_pressed():
	go_to_sub_menu.emit("settings_menu")
	$SFXPlayer.play_sound()
