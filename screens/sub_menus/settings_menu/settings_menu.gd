extends Control

signal go_back
signal toogle_music_playing

@export var music_on_vslider_theme : Theme
@export var music_off_vslider_theme : Theme
@export var sfx_on_vslider_theme : Theme
@export var sfx_off_vslider_theme : Theme

var _saved_settings : UserSettings

@onready var _music_vertical_slider : FlagVerticalSlider = $MusicVerticalSlider
@onready var _sfx_vertical_slider : FlagVerticalSlider = $SFXVerticalSlider
@onready var _sfx_volume_selection_player : SFXPlayer = $SFXVolumeSelectionPlayer

func _ready():
	_get_saved_user_settings()
	_set_volume_sliders()

func _get_saved_user_settings():
	_saved_settings = UserDataManager.user_data.user_settings

func _set_volume_sliders():
	_update_volume_sliders_themes()
	_music_vertical_slider.sound_enabling_toggled.connect(_on_music_slider_sound_enabling_toggled)
	_sfx_vertical_slider.sound_enabling_toggled.connect(_on_sfx_slider_sound_enabling_toggled)
	_music_vertical_slider.value = _saved_settings.music_volume_value
	_sfx_vertical_slider.value = _saved_settings.sfx_volume_value


func _update_volume_sliders_themes():
	if _saved_settings.music_enabled:
		_music_vertical_slider.theme = music_on_vslider_theme
	else:
		_music_vertical_slider.theme = music_off_vslider_theme
	
	if _saved_settings.sfx_enabled:
		_sfx_vertical_slider.theme = sfx_on_vslider_theme
	else:
		_sfx_vertical_slider.theme = sfx_off_vslider_theme


func _on_music_slider_sound_enabling_toggled(sound_enabled:bool):
	update_saved_volume_settings()
	
	_saved_settings.music_enabled = sound_enabled
	_update_volume_sliders_themes()
	UserDataManager.save_user_data_to_disk()

	toogle_music_playing.emit()

func _on_sfx_slider_sound_enabling_toggled(sound_enabled:bool):
	update_saved_volume_settings()
	
	_saved_settings.sfx_enabled = sound_enabled
	_update_volume_sliders_themes()
	UserDataManager.save_user_data_to_disk()

func update_saved_volume_settings():
	_saved_settings.music_volume_value = _music_vertical_slider.value
	_saved_settings.sfx_volume_value = _sfx_vertical_slider.value

func _on_go_back_button_pressed():
	update_saved_volume_settings()
	UserDataManager.save_user_data_to_disk()
	$GoBackBtnSFXPlayer.play_sound()
	go_back.emit()


func _on_sfx_vertical_slider_drag_ended(_value_changed):
	_sfx_volume_selection_player.play_sound()
