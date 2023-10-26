extends Node

@export var user_data : UserData  

func _init():
	user_data = UserDataPersistent.load_from_disk()
	
	if user_data.player_user_data.player_name == "":
		
		user_data.player_user_data.player_name = "Default User"
		user_data.player_user_data.player_balance = 0
		
		user_data.user_settings.music_enabled = true
		user_data.user_settings.sfx_enabled = true
		user_data.user_settings.music_volume_value = 0.5
		user_data.user_settings.sfx_volume_value = 0.5
		
		user_data.games_menu_user_data.worlds = [
			load("res://data/worlds/snowstorm/snowstorm.tres").duplicate(true) as World,
			load("res://data/worlds/trenches/trenches.tres").duplicate(true) as World,
			load("res://data/worlds/city_lights/city_lights.tres").duplicate(true) as World
			]
		user_data.games_menu_user_data.selected_world_index = 0
		
		for world in user_data.games_menu_user_data.worlds:
			if world.levels.size() != 0:
				world.selected_level = world.levels[0]
	
func save_user_data_to_disk():
	UserDataPersistent.save_to_disk(user_data)

func load_user_data_from_disk() -> UserData:
	return user_data


#func update_games_menu_user_data(new_value:GamesMenuUserData):
#	user_data.games_menu_user_data = new_value
#	save_user_data_to_disk()
#
#func update_user_settings(new_value:UserSettings):
#	user_data.user_settings = new_value
#	save_user_data_to_disk()

