extends Node2D

var display_games_menu_directly : bool

func _ready():
	($MainMenu as MainMenu).go_to_sub_menu.connect(_go_to_sub_menu)
	if display_games_menu_directly:
		_display_games_menu()

func _on_toggle_music_playing():
	MusicManager.play_main_stream()

func _go_to_sub_menu(sub_menu_name:String):
	var sub_menu:Node = load("res://screens/sub_menus/"+ sub_menu_name+"/"+ sub_menu_name+".tscn").instantiate()

	if sub_menu_name == "settings_menu":
		sub_menu.connect("toogle_music_playing", _on_toggle_music_playing)

	SceneManagerSystem.get_container("SubMenuContainer").goto_scene(sub_menu)

	await get_tree().create_timer(0.2).timeout

	var tween = create_tween()
	tween.tween_property($".", "position", Vector2(-1920, 0), 0.5)

	($SubMenuContainer.get_child(0)).go_back.connect(go_to_main_menu)

func go_to_main_menu():
	var tween = create_tween()
	tween.tween_property($".", "position", Vector2(0, 0), 0.5)

func _display_games_menu():
	var games_menu:Node = load("res://screens/sub_menus/games_menu/games_menu.tscn").instantiate()
	
	SceneManagerSystem.get_container("SubMenuContainer").goto_scene(games_menu)
	self.position = Vector2(-1920, 0)
	($SubMenuContainer.get_child(0)).go_back.connect(go_to_main_menu)
	
	
func _exit_tree():
	if $SubMenuContainer.get_child_count() != 0:
		if $SubMenuContainer.get_child(0).name == "SettingsMenu":
			$SubMenuContainer.get_child(0).update_saved_volume_settings()
			UserDataManager.save_user_data_to_disk()
