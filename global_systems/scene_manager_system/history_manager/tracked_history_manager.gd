class_name TrackedHistoryManager extends IHistoryManager

var _scene_history : Array = []
var _previous_instantiated_scene : Node
var _current_instantiated_scene : Node

var _theme = "theme_1"

func add_new_scene(instantiated_scene_to_go) -> void:
	_current_instantiated_scene = instantiated_scene_to_go
	_scene_history.push_back(instantiated_scene_to_go.scene_file_path)
	_previous_instantiated_scene = _instantiate_previous_scene_from_history()

func remove_last_scene() -> void:
	_current_instantiated_scene = _previous_instantiated_scene
	_scene_history.pop_back()
	_previous_instantiated_scene = _instantiate_previous_scene_from_history() 

func update_themes(new_theme) -> void:
	for ii in _scene_history.size():
		_scene_history[ii] = _scene_history[ii].trim_suffix(_theme + ".tscn") + new_theme + ".tscn"
	_current_instantiated_scene = _instantiate_current_scene_from_history()
	_previous_instantiated_scene = _instantiate_previous_scene_from_history() 
	_theme = new_theme

func _instantiate_previous_scene_from_history() -> Node:
	return load(_scene_history[-2]).instantiate() if _scene_history.size() > 1 else null

func _instantiate_current_scene_from_history() -> Node:
	return load(_scene_history[-1]).instantiate() if _scene_history.size() > 0 else null

func get_current_instantiated_scene() -> Node:
	return _current_instantiated_scene

func get_previous_instantiated_scene() -> Node:
	return _previous_instantiated_scene
