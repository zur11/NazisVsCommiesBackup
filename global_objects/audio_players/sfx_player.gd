class_name SFXPlayer extends AudioStreamPlayer

var _user_settings : UserSettings = UserDataManager.user_data.user_settings

func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	self.bus = "SFX"
	var bus_index : int = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(_user_settings.sfx_volume_value))

func play_sound():
	if _user_settings.sfx_enabled:
		self.play()
	else:
		self.stop()
