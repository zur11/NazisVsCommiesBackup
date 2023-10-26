class_name PausedGamePopup extends Control

var level_to_replay : Level

var _saved_settings := UserDataManager.user_data.user_settings

@onready var _music_horizontal_slider : HSlider = $"%MusicHorizontalSlider"
@onready var _sfx_horizontal_slider : HSlider = $"%SFXHorizontalSlider"
@onready var _sfx_volume_selection_player : SFXPlayer = $SFXVolumeSelectionPlayer
@onready var _generic_btn_pressed_player : SFXPlayer = $GenericBtnPressedPlayer

func _ready():
	_set_volume_sliders()

func _set_volume_sliders():
	_music_horizontal_slider.sound_enabling_toggled.connect(_on_music_slider_sound_enabling_toggled)
	_sfx_horizontal_slider.sound_enabling_toggled.connect(_on_sfx_slider_sound_enabling_toggled)
	_music_horizontal_slider.value = _saved_settings.music_volume_value
	_sfx_horizontal_slider.value = _saved_settings.sfx_volume_value

func _update_saved_volume_settings():
	_saved_settings.music_volume_value = _music_horizontal_slider.value
	_saved_settings.sfx_volume_value = _sfx_horizontal_slider.value



func _on_music_slider_sound_enabling_toggled(sound_enabled:bool):
	_update_saved_volume_settings()
	
	_saved_settings.music_enabled = sound_enabled
	UserDataManager.save_user_data_to_disk()
	
	MusicManager.play_game_stream(level_to_replay)

func _on_sfx_slider_sound_enabling_toggled(sound_enabled:bool):
	_update_saved_volume_settings()
	
	_saved_settings.sfx_enabled = sound_enabled
	UserDataManager.save_user_data_to_disk()
	
func _on_resume_game_button_pressed():
	_generic_btn_pressed_player.play_sound()
	_update_saved_volume_settings()
	UserDataManager.save_user_data_to_disk()
	
	get_tree().paused = false
	self.visible = false

func _on_retry_level_button_pressed():
	var destiny_screen : GameScreen = load("res://screens/game_screen/game_screen.tscn").instantiate() as GameScreen
	destiny_screen.level = level_to_replay
	
	_generic_btn_pressed_player.play_sound()
	
	_update_saved_volume_settings()
	UserDataManager.save_user_data_to_disk()
	
	await get_tree().create_timer(1).timeout
	get_tree().paused = false
	MusicManager.play_game_stream(level_to_replay)
	SceneManagerSystem.get_container("ScreenContainer").goto_scene(destiny_screen)


func _on_go_to_main_menu_button_pressed():
	var menus_screen : Node = load("res://screens/menus/menus.tscn").instantiate()
	
	_generic_btn_pressed_player.play_sound()
	
	_update_saved_volume_settings()
	UserDataManager.save_user_data_to_disk()
	
	await get_tree().create_timer(1).timeout
	get_tree().paused = false
	MusicManager.play_main_stream()
	SceneManagerSystem.get_container("ScreenContainer").goto_scene(menus_screen)

func _on_sfx_horizontal_slider_drag_ended(_value_changed):
	_sfx_volume_selection_player.play_sound()
