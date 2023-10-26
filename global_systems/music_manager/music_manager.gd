extends AudioStreamPlayer

const _MAIN_STREAM_PATH : String = "res://assets/audio/music/soviet_dark_carnival_loop2.mp3"
const _SNOWSTORM_GAME_STREAM_PATH : String = "res://data/worlds/snowstorm/winter-no-wind.mp3"
const _TRENCHES_GAME_STREAM_PATH : String = "res://data/worlds/trenches/russian-girl.mp3" 
const _CITY_LIGHTS_GAME_STREAM_PATH : String = "res://data/worlds/city_lights/luna-park.mp3"
const _ALLIES_SELECTOR_POPUP_STREAM_PATH : String = "res://assets/audio/music/marionettes_(choosimg_allies_music).mp3"

var _user_settings : UserSettings = UserDataManager.user_data.user_settings

var _allies_selector_popup_stream : AudioStreamMP3
var _main_stream : AudioStreamMP3
var _game_stream : AudioStreamMP3


func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	self.bus = "Music"
	var bus_index : int = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(_user_settings.music_volume_value))
	_allies_selector_popup_stream = load(_ALLIES_SELECTOR_POPUP_STREAM_PATH)
	_main_stream = load(_MAIN_STREAM_PATH)
	self.stream = _main_stream

func play_main_stream():
	if self.playing:
		self.stop()
	
	self.stream = _main_stream
	_play_music()

func play_game_stream(game_level:Level):
	if game_level is LevelSnowstorm:
		_game_stream = load(_SNOWSTORM_GAME_STREAM_PATH)
	elif game_level is LevelTrenches:
		_game_stream = load(_TRENCHES_GAME_STREAM_PATH)
	elif game_level is LevelCityLights:
		_game_stream = load(_CITY_LIGHTS_GAME_STREAM_PATH)
		
	if self.playing:
		self.stop()

	self.stream = _game_stream
	_play_music()

func play_allies_selector_popup_stream():
	if self.playing:
		self.stop()
		
	self.stream = _allies_selector_popup_stream
	_play_music()

func _play_music():
	var user_settings = UserDataManager.user_data.user_settings
	
	if user_settings.music_enabled:
		self.play()
	else:
		self.stop()

	
