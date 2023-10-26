extends Control

var loading_animation_index = 0

var _game_screen_scene_path : String = "res://screens/game_screen/game_screen.tscn"
var _main_menu_scene_path : String = "res://screens/main_menu/main_menu.tscn"
var _settings_menu_scene_path : String = "res://screens/sub_menus/settings_menu/settings_menu.tscn"
var _games_menu_scene_path : String = "res://screens/sub_menus/games_menu/games_menu.tscn"
var _menus_scene_path : String = "res://screens/menus/menus.tscn"

@onready var loading_animations_container := $"LoadingAnimationsContainer"

func _ready():
	MusicManager.play_main_stream()
	loading_animations_container.get_child(loading_animation_index).play_loading_animation(loading_animation_index, _game_screen_scene_path)
	for loading_animation in loading_animations_container.get_children():
		loading_animation.connect("loading_animation_ended",_play_next_animation)
		
func _play_next_animation():
	loading_animation_index += 1
	if loading_animation_index < loading_animations_container.get_child_count():
		if loading_animation_index == 1:
			loading_animations_container.get_child(loading_animation_index).play_loading_animation(loading_animation_index, _main_menu_scene_path)
		
		elif loading_animation_index == 2:
			loading_animations_container.get_child(loading_animation_index).play_loading_animation(loading_animation_index, _settings_menu_scene_path)
		
		elif loading_animation_index == 3:
			loading_animations_container.get_child(loading_animation_index).play_loading_animation(loading_animation_index, _games_menu_scene_path)
		
		elif loading_animation_index == 4:
			loading_animations_container.get_child(loading_animation_index).play_loading_animation(loading_animation_index, _menus_scene_path)
		
	else:
		var menus_screen : Node = load("res://screens/menus/menus.tscn").instantiate()
		
		await get_tree().create_timer(0.5).timeout
		
		SceneManagerSystem.get_container("ScreenContainer").goto_scene(menus_screen)
		SceneManagerSystem.get_container("CurtainSceneContainer").exit_scene()
