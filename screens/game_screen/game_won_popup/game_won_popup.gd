class_name GameWonPopup extends Control

#signal display_balance_displayer(coins_to_add:int)

var _level : Level : set = _set_level
var level_to_replay : Level

var level_reward_ally_already_adquired : bool 
var special_coin_reward_activated : bool
var _passing_to_next_world : bool

var _game_screen_user_data : GameScreenUserData 
var _player_user_data : PlayerUserData 
var _games_menu_user_data : GamesMenuUserData

var _worlds : Array[World]
var _current_world_index : int 
var _current_world : World 
var _current_level_index : int 

var _next_world : World
var _next_level : Level


@onready var congratulations_label : Label = $WinningCongratulationsLabel

@onready var _reward_container_no_title : TextureRect = $RewardContainerNoTitle
@onready var _coins_reward_thumbnail : TextureRect = $CoinsRewardThumbnail
@onready var _coin_decoration : TextureRect = $CoinDecoration

@onready var _ally_thumbnail : TextureRect = $AllyThumbnail
@onready var _description_label : Label = $DescriptionLabel

@onready var _generic_btn_pressed_player : SFXPlayer = $GenericBtnPressedPlayer
@onready var _reward_label : Label = $RewardLabel

@onready var _continue_button : TextureButton = $ContinueButton


func _ready():
	_get_saved_user_data()
	_update_levels_and_worlds()

func _set_level(new_value:Level):
	_level = new_value
	
	if _level == null:
		_set_popup_elements_with_coin_reward()
		return
	
	if _level.special_coin_reward != 0 and not level_reward_ally_already_adquired:
		special_coin_reward_activated = true
		
	if not level_reward_ally_already_adquired:
		_set_popup_elements_with_ally_reward()
	else:
		_set_popup_elements_with_coin_reward()

func _get_saved_user_data():
	_game_screen_user_data = UserDataManager.user_data.game_screen_user_data
	_player_user_data = UserDataManager.user_data.player_user_data
	_games_menu_user_data = UserDataManager.user_data.games_menu_user_data
	
	_worlds = _games_menu_user_data.worlds
	_current_world_index = _games_menu_user_data.selected_world_index
	_current_world = _worlds[_current_world_index]
	_current_level_index = _game_screen_user_data.current_level_index


func _update_levels_and_worlds():
	if not _current_level_index == _current_world.levels.size() - 1:
		
#		if _current_world.world_name == "Trenches" and _current_level_index == 3:
#			printt("Demo Finished") 
#
#			_continue_button.disabled = true
#			_next_level = null
#			level_reward_ally_already_adquired = true
#			return
		
		_next_level = _current_world.levels[_current_level_index + 1].duplicate(true) # Changing elements of class-typed arrays requires duplicating those elements in order to edit and save them to disk
		
	else:
		if _current_world.world_name == "Trenches":
			printt("last world won") # Last World Won Special popup Congratulations
			
			_continue_button.disabled = true
			_next_level = null
			level_reward_ally_already_adquired = true
			return
		
		_next_world = _games_menu_user_data.worlds[_current_world_index + 1]
		_next_level = _next_world.levels[0].duplicate(true)
		
		_passing_to_next_world = true
		
	if _next_level.level_unlocked:
		level_reward_ally_already_adquired = true

	_level = _current_world.levels[_current_level_index]

func _set_popup_elements_with_ally_reward():
	var ally_thumbnail_texture : Texture = GlobalConstants.ally_thumbnails_list[_level.ally_presentation.ally_thumbnail]
	var rewarded_ally_description : String = _level.ally_presentation.ally_reward_description
	
	_ally_thumbnail.texture = ally_thumbnail_texture
	_description_label.text = rewarded_ally_description
	
	if special_coin_reward_activated:
		_reward_container_no_title.visible = true
		_reward_label.visible = true
		_reward_label.text = "+" + str(_level.special_coin_reward)
		_coin_decoration.visible = true

func _set_popup_elements_with_coin_reward():
	_reward_container_no_title.visible = true
	_coins_reward_thumbnail.visible = true
	_reward_label.visible = true
	_reward_label.text = "+" + str(_level.level_coins_reward) 
	_coin_decoration.visible = true
	_description_label.text = "EXTRA GOLD COINS: \nYou have earned a reward for re-winning this level, use them to buy fun products in the shop!"

func _on_continue_button_pressed():
	var destiny_screen : Node 
	
	if _next_level != null:
		_next_level.level_unlocked = true
	
	if _passing_to_next_world:
		destiny_screen = load("res://screens/menus/menus.tscn").instantiate()
		destiny_screen.display_games_menu_directly = true
		
		_next_world.levels[0] = _next_level
		_current_world.selected_level = _current_world.levels[0]
		_next_world.selected_level = _next_level
		_games_menu_user_data.selected_world_index += 1
		
	else:
		destiny_screen = load("res://screens/game_screen/game_screen.tscn").instantiate() as GameScreen
		destiny_screen.level = _next_level.duplicate(true)
		
		
		_current_world.levels[_current_level_index + 1] = _next_level # Placing duplicated element back in the array that is going to be saved
		_current_world.selected_level = _next_level
		_game_screen_user_data.current_level_index += 1
		_current_level_index += 1
	
	if level_reward_ally_already_adquired:
		_player_user_data.player_balance += _level.level_coins_reward
	else:
		if special_coin_reward_activated:
			_player_user_data.player_balance += _level.special_coin_reward
	
	UserDataManager.save_user_data_to_disk()
	_generic_btn_pressed_player.play_sound()
	
	get_tree().paused = false 
	SceneManagerSystem.get_container("ScreenContainer").goto_scene(destiny_screen)


func _on_go_to_main_menu_button_pressed():
	var menus_screen : Node = load("res://screens/menus/menus.tscn").instantiate()
	if _next_level != null:
		_next_level.level_unlocked = true
#	menus_screen.display_games_menu_directly = true
	else:
		_generic_btn_pressed_player.play_sound()
		await get_tree().create_timer(1).timeout
		
		get_tree().paused = false
		MusicManager.play_main_stream()
		SceneManagerSystem.get_container("ScreenContainer").goto_scene(menus_screen)
		return

	if _passing_to_next_world:
		_next_world.levels[0] = _next_level
		_current_world.selected_level = _current_world.levels[0]
		_next_world.selected_level = _next_level
		_games_menu_user_data.selected_world_index += 1
	else:
		_current_world.levels[_current_level_index + 1] = _next_level # Placing duplicated element back in the array that is going to be saved
		_current_world.selected_level = _next_level
		_game_screen_user_data.current_level_index += 1
	
	if level_reward_ally_already_adquired:
		_player_user_data.player_balance += _level.level_coins_reward
	else:
		if special_coin_reward_activated:
			_player_user_data.player_balance += _level.special_coin_reward
	
	UserDataManager.save_user_data_to_disk()
	
	_generic_btn_pressed_player.play_sound()
	await get_tree().create_timer(1).timeout
	
	get_tree().paused = false
	MusicManager.play_main_stream()
	SceneManagerSystem.get_container("ScreenContainer").goto_scene(menus_screen)


func _on_retry_level_button_pressed():
	var destiny_screen : GameScreen = load("res://screens/game_screen/game_screen.tscn").instantiate() as GameScreen
	
	if _next_level != null:
		_next_level.level_unlocked = true
		_current_world.levels[_current_level_index + 1] = _next_level # Placing duplicated element back in the array that is going to be saved
	
	else:
		destiny_screen.level = level_to_replay
		_generic_btn_pressed_player.play_sound()
		await get_tree().create_timer(1).timeout
		
		get_tree().paused = false
		SceneManagerSystem.get_container("ScreenContainer").goto_scene(destiny_screen)
		return
	
	if level_reward_ally_already_adquired:
		_player_user_data.player_balance += _level.level_coins_reward
	else:
		if special_coin_reward_activated:
			_player_user_data.player_balance += _level.special_coin_reward

	UserDataManager.save_user_data_to_disk()
	
	destiny_screen.level = level_to_replay
	
	_generic_btn_pressed_player.play_sound()
	await get_tree().create_timer(1).timeout
	
	get_tree().paused = false
	SceneManagerSystem.get_container("ScreenContainer").goto_scene(destiny_screen)
