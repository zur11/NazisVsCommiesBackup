class_name UntrackedHistoryManager extends IHistoryManager

var _current_instantiated_scene : Node
var _theme = "theme_1"

func add_new_scene(instantiated_scene_to_go):
	_current_instantiated_scene = instantiated_scene_to_go

func update_themes(new_theme) -> void:
	var new_current_instantiated_scene_path = _current_instantiated_scene.scene_file_path.trim_suffix(_theme + ".tscn") + new_theme + ".tscn"
	_current_instantiated_scene = load(new_current_instantiated_scene_path).instantiate()
	_theme = new_theme

func get_current_instantiated_scene() -> Node:
	return _current_instantiated_scene

func get_previous_instantiated_scene() -> Node:
	push_warning("Trying to go back in a not historied container")
	return null
