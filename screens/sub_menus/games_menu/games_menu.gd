extends Control

signal go_back

var _level_selector: LevelSelector
var _loading_new_world : bool

@onready var _world_selector : WorldSelector = $WorldSelector
@onready var _background_texture : TextureRect = $BackgroundTexture


func _ready():
	_set_world_selector()
	_set_level_selector()

func _set_world_selector():
	_world_selector.connect("world_selected", _on_world_selected_set_selected_world)
	_world_selector.initial_setup()

	_world_selector.position = Vector2(360,658)

func _set_level_selector():
	_level_selector = load("res://screens/sub_menus/games_menu/level_selector/level_selector.tscn").instantiate()
	self.add_child(_level_selector)
	_level_selector.initial_setup()
	_level_selector.position.y = -570
	
	await get_tree().create_timer(1).timeout
	
	var tween = create_tween()
	tween.tween_property(_level_selector, "position", Vector2(0, 0), 0.1).set_ease(Tween.EASE_OUT_IN)
	_level_selector.connect("go_to_level", _on_level_selector_go_to_level)

func _on_world_selected_set_selected_world(selected_world:World):
	_background_texture.texture = selected_world.games_menu_background
	_change_level_selector_display()

func _change_level_selector_display():
	if !_level_selector: return
	
	_loading_new_world = true
	
	_world_selector.disable_all_world_buttons()
	var tween = create_tween()
	tween.tween_property(_level_selector, "position", Vector2(0, -600), 0.5).set_ease(Tween.EASE_OUT_IN)
	
	await get_tree().create_timer(0.5).timeout
	_level_selector.display_selected_world_levels()
	
	var tween2 = create_tween()
	tween2.tween_property(_level_selector, "position", Vector2(0, 0), 0.5).set_ease(Tween.EASE_OUT_IN)
	
	await get_tree().create_timer(0.5).timeout
	
	_world_selector.enable_all_world_buttons()
	
	_loading_new_world = false

func _update_user_data(selected_level:Level):
	var games_menu_user_data : GamesMenuUserData = UserDataManager.user_data.games_menu_user_data
	var game_screen_user_data : GameScreenUserData = UserDataManager.user_data.game_screen_user_data
	
	var current_world : World = games_menu_user_data.worlds[games_menu_user_data.selected_world_index]
	
	for ii in current_world.levels.size():
		if current_world.levels[ii].level_name == selected_level.level_name:
			game_screen_user_data.current_level_index = ii
			game_screen_user_data.total_rows_number = current_world.total_rows_number
	
	UserDataManager.save_user_data_to_disk()

func _on_level_selector_go_to_level(level:Level):
	if not level.level_unlocked: return 
	var destiny_screen : GameScreen = load("res://screens/game_screen/game_screen.tscn").instantiate() as GameScreen
	destiny_screen.level = level.duplicate(true)
	
	var container_to_erase : SceneContainer = SceneManagerSystem.get_container_node("SubMenuContainer")

	_update_user_data(level)
	container_to_erase.unregister_in_system()
	SceneManagerSystem.get_container("ScreenContainer").goto_scene(destiny_screen)

func _on_go_back_button_pressed():
	if _loading_new_world: return
	
	$SFXPlayer.play_sound()
	_level_selector.queue_free()
	_world_selector.queue_free()
	go_back.emit()

