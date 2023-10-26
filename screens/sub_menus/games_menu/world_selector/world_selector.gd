@tool
class_name WorldSelector extends Control

signal world_selected(world:World)

@export var _games_menu_user_data : GamesMenuUserData

var _worlds : Array[World] 
var _selected_world_index : int


func _ready():
	if Engine.is_editor_hint() and _worlds.size() != 0 and self.get_child_count() != 0:
		for world_button in self.get_children():
			world_button.texture_normal = world_button.world.normal_button_texture

func initial_setup():
	_get_user_data()
	_set_world_buttons()
	_set_initial_selected_world()

func disable_all_world_buttons():
	for world_button in self.get_children():
		world_button.disabled = true

func enable_all_world_buttons():
	for world_button in self.get_children():
		world_button.disabled = false

func _get_user_data():
	var user_data : UserData = UserDataManager.user_data
	_games_menu_user_data = user_data.games_menu_user_data
	_worlds = _games_menu_user_data.worlds
	_selected_world_index = _games_menu_user_data.selected_world_index


func _set_world_buttons():
	for ii in self.get_child_count():
		var world_button = self.get_child(ii) as WorldButton
		
		world_button.world = _worlds[ii]
		
#		if world.world_unlocked:
			
		
		if ii == _selected_world_index:
			world_button.is_selected = true
		else:
			world_button.is_selected = false

		world_button.connect("pressed", _on_world_button_pressed.bind(ii))

func _set_initial_selected_world():
	_update_user_data()
	_emit_world_selected_signal(_worlds[_selected_world_index])

func _update_selected_world_index(new_value:int):
	var previous_selected_world_button = self.get_child(_selected_world_index) as WorldButton
	var selected_world_button = self.get_child(new_value) as WorldButton
	
	_selected_world_index = new_value
	
	previous_selected_world_button.is_selected = false
	selected_world_button.is_selected = true

func _update_user_data(): 
	_games_menu_user_data.selected_world_index = _selected_world_index

	UserDataManager.save_user_data_to_disk()

func _on_world_button_pressed(new_value:int):
	if new_value == _selected_world_index: return
	_update_selected_world_index(new_value)
	_update_user_data()
	_emit_world_selected_signal(_worlds[_selected_world_index])
	
func _emit_world_selected_signal(new_value:World):
	world_selected.emit(new_value)
	
func _exit_tree():
	if not Engine.is_editor_hint():
		_update_user_data()
