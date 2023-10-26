class_name GameOverPopup extends Control

var level_to_replay : Level

@onready var _generic_btn_pressed_player : SFXPlayer = $GenericBtnPressedPlayer

func _on_go_to_main_menu_button_pressed():
	var menus_screen : Node = load("res://screens/menus/menus.tscn").instantiate()
	
	_generic_btn_pressed_player.play_sound()
	await get_tree().create_timer(1).timeout
	
	get_tree().paused = false
	MusicManager.play_main_stream()
	SceneManagerSystem.get_container("ScreenContainer").goto_scene(menus_screen)


func _on_play_again_button_pressed():
	var destiny_screen : GameScreen = load("res://screens/game_screen/game_screen.tscn").instantiate() as GameScreen
	destiny_screen.level = level_to_replay
	
	_generic_btn_pressed_player.play_sound()
	await get_tree().create_timer(1).timeout
	
	get_tree().paused = false
	MusicManager.play_game_stream(level_to_replay)
	SceneManagerSystem.get_container("ScreenContainer").goto_scene(destiny_screen)
